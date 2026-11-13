import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure.dart';
import '../../catalog/domain/catalog_models.dart';
import '../data/download_api.dart';
import '../data/download_file_store.dart';
import '../data/download_store.dart';
import '../data/media_downloader.dart';
import '../domain/download_models.dart';

final downloadStoreProvider = Provider<DownloadStore>(
  (ref) => DownloadStore(ref.watch(sharedPreferencesProvider)),
);

final downloadFileStoreProvider = Provider<DownloadFileStore>(
  (ref) => const DownloadFileStore(),
);

final downloadApiProvider = Provider<DownloadApi>(
  (ref) => DownloadApi(ref.watch(apiClientProvider)),
);

final mediaDownloaderProvider = Provider<MediaDownloader>(
  (ref) => DioMediaDownloader(ref.watch(apiClientProvider)),
);

/// Owns the device-local downloads: metadata, progress and files.
///
/// The API only mints short-lived grants; everything after the redirect is
/// handled here so downloads keep working while offline.
class DownloadsController extends Notifier<List<DownloadItem>> {
  late final DownloadApi _api;
  late final DownloadStore _store;
  late final DownloadFileStore _files;
  late final MediaDownloader _downloader;

  final _tokens = <String, CancelToken>{};
  final _lastProgressAt = <String, DateTime>{};

  @override
  List<DownloadItem> build() {
    _api = ref.read(downloadApiProvider);
    _store = ref.read(downloadStoreProvider);
    _files = ref.read(downloadFileStoreProvider);
    _downloader = ref.read(mediaDownloaderProvider);
    final restored = _store.load();
    unawaited(_reconcile(restored));
    return restored;
  }

  /// Drops downloads whose file disappeared and interrupted transfers.
  Future<void> _reconcile(List<DownloadItem> restored) async {
    final next = <DownloadItem>[];
    var changed = false;
    for (final item in restored) {
      if (item.isCompleted) {
        if (await _files.exists(item.filePath)) {
          next.add(item);
        } else {
          changed = true;
        }
        continue;
      }
      if (item.isDownloading) {
        // The app stopped mid-transfer; remove the partial file and the row.
        await _files.delete(item.filePath);
        changed = true;
        continue;
      }
      next.add(item);
    }
    if (changed) {
      state = next;
      await _persist();
    }
  }

  /// Starts (or restarts) a download for the given title/episode.
  Future<DownloadItem?> start({
    required TitleDetail detail,
    Episode? episode,
    String? profileId,
  }) {
    final runtimeMinutes = (episode?.runtimeMinutes ?? 0) > 0
        ? episode!.runtimeMinutes
        : detail.runtimeMinutes;
    return _start(
      titleId: detail.id,
      titleName: detail.name,
      posterPath: detail.posterPath,
      episode: episode,
      durationSeconds: runtimeMinutes * 60,
      profileId: profileId,
    );
  }

  Future<DownloadItem?> _start({
    required String titleId,
    required String titleName,
    required String posterPath,
    required Episode? episode,
    required int durationSeconds,
    required String? profileId,
  }) async {
    final id = buildDownloadId(titleId, episode?.id);
    final existing = _find(id);
    if (existing != null && existing.isDownloading) return existing;
    if (existing != null && existing.isCompleted) return existing;
    if (_tokens.containsKey(id)) return existing;

    final session = await _api.create(titleId: titleId, episodeId: episode?.id);
    final path = await _files.resolve(session.fileName);
    await _files.delete(path);

    var item = DownloadItem(
      titleId: titleId,
      titleName: titleName,
      posterPath: posterPath.isEmpty ? session.posterPath : posterPath,
      filePath: path,
      createdAt: DateTime.now(),
      episode: episode == null
          ? session.episode
          : DownloadEpisode(
              id: episode.id,
              number: episode.number,
              seasonNumber: episode.seasonNumber,
              name: episode.name,
              runtimeMinutes: episode.runtimeMinutes,
            ),
      durationSeconds: durationSeconds > 0
          ? durationSeconds
          : session.durationSeconds,
      profileId: profileId ?? '',
    );
    _replace(item);
    await _persist();
    item = _find(id) ?? item;

    final cancelToken = CancelToken();
    _tokens[id] = cancelToken;
    // The transfer continues in the background so the UI can show progress
    // immediately; grant and file-system failures surface before this point.
    unawaited(
      _transfer(
        id: id,
        url: session.downloadUrl,
        path: path,
        cancelToken: cancelToken,
      ),
    );
    return _find(id);
  }

  Future<void> _transfer({
    required String id,
    required String url,
    required String path,
    required CancelToken cancelToken,
  }) async {
    try {
      await _downloader.download(
        url: url,
        path: path,
        cancelToken: cancelToken,
        onProgress: (received, total) => _onProgress(id, received, total),
      );
      final size = await _files.size(path);
      _update(
        id,
        (current) => current.copyWith(
          status: DownloadStatus.completed,
          receivedBytes: size > 0 ? size : current.receivedBytes,
          totalBytes: size > 0 ? size : current.totalBytes,
          clearError: true,
        ),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      await _files.delete(path);
      _update(
        id,
        (current) => current.copyWith(
          status: DownloadStatus.failed,
          error: error.message ?? 'download failed',
        ),
      );
    } on Object catch (error) {
      await _files.delete(path);
      _update(
        id,
        (current) => current.copyWith(
          status: DownloadStatus.failed,
          error: error.toString(),
        ),
      );
    } finally {
      _tokens.remove(id);
      _lastProgressAt.remove(id);
      await _persist();
    }
  }

  /// Cancels an in-flight download and removes its partial file.
  Future<void> cancel(String id) async {
    _tokens.remove(id)?.cancel('cancelled');
    final item = _find(id);
    if (item == null) return;
    state = state.where((entry) => entry.id != id).toList(growable: false);
    await _persist();
    await _files.delete(item.filePath);
  }

  /// Deletes a completed or failed download.
  Future<void> remove(String id) async {
    await cancel(id);
  }

  /// Removes every download owned by a profile, including its files.
  Future<void> removeForProfile(String profileId) async {
    final targets = state
        .where((item) => item.profileId == profileId)
        .toList(growable: false);
    for (final item in targets) {
      _tokens.remove(item.id)?.cancel('profile removed');
      await _files.delete(item.filePath);
    }
    state = state
        .where((item) => item.profileId != profileId)
        .toList(growable: false);
    await _persist();
  }

  /// The completed download for a title/episode, if it is on this device.
  DownloadItem? completedFor(String titleId, String? episodeId) {
    for (final item in state) {
      if (item.isCompleted &&
          item.titleId == titleId &&
          item.episode?.id == episodeId) {
        return item;
      }
    }
    return null;
  }

  void _onProgress(String id, int received, int total) {
    final now = DateTime.now();
    final last = _lastProgressAt[id];
    if (total > 0 &&
        received < total &&
        last != null &&
        now.difference(last) < const Duration(milliseconds: 200)) {
      return;
    }
    _lastProgressAt[id] = now;
    _update(
      id,
      (item) => item.copyWith(
        receivedBytes: received,
        totalBytes: total > 0 ? total : item.totalBytes,
      ),
    );
  }

  DownloadItem? _find(String id) {
    for (final item in state) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _replace(DownloadItem item) {
    state = [
      ...state.where((entry) => entry.id != item.id),
      item,
    ];
  }

  void _update(String id, DownloadItem Function(DownloadItem item) transform) {
    var found = false;
    final next = <DownloadItem>[];
    for (final item in state) {
      if (item.id == id) {
        found = true;
        next.add(transform(item));
      } else {
        next.add(item);
      }
    }
    if (found) state = next;
  }

  Future<void> _persist() => _store.save(state);
}

final downloadsControllerProvider =
    NotifierProvider<DownloadsController, List<DownloadItem>>(
      DownloadsController.new,
    );
