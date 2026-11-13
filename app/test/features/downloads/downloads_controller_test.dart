import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedvideo/features/catalog/domain/catalog_models.dart';
import 'package:speedvideo/features/downloads/data/download_api.dart';
import 'package:speedvideo/features/downloads/data/download_file_store.dart';
import 'package:speedvideo/features/downloads/data/download_store.dart';
import 'package:speedvideo/features/downloads/data/media_downloader.dart';
import 'package:speedvideo/features/downloads/domain/download_models.dart';
import 'package:speedvideo/features/downloads/presentation/downloads_controller.dart';

class _FakeDownloadApi implements DownloadApi {
  int calls = 0;

  @override
  Future<DownloadSession> create({
    required String titleId,
    String? episodeId,
  }) async {
    calls++;
    return DownloadSession(
      downloadUrl: 'https://media.example.com/$titleId.mp4',
      titleId: titleId,
      fileName: 'file-$titleId.mp4',
      durationSeconds: 2700,
    );
  }
}

class _FakeFileStore implements DownloadFileStore {
  static const fileSize = 2048;
  final deleted = <String>[];

  @override
  Future<String> resolve(String fileName) async => '/downloads/$fileName';

  @override
  Future<bool> exists(String path) async => false;

  @override
  Future<int> size(String path) async => fileSize;

  @override
  Future<void> delete(String path) async => deleted.add(path);
}

class _CompletingDownloader implements MediaDownloader {
  @override
  Future<void> download({
    required String url,
    required String path,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) async {
    onProgress(1024, 2048);
    onProgress(2048, 2048);
  }
}

class _PendingDownloader implements MediaDownloader {
  final completer = Completer<void>();

  @override
  Future<void> download({
    required String url,
    required String path,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) {
    onProgress(512, 2048);
    return completer.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> buildContainer({
    required DownloadStore store,
    required _FakeFileStore files,
    required MediaDownloader downloader,
    DownloadApi? api,
  }) async {
    final container = ProviderContainer(
      overrides: [
        downloadApiProvider.overrideWithValue(
          api ?? _FakeDownloadApi(),
        ),
        downloadStoreProvider.overrideWithValue(store),
        downloadFileStoreProvider.overrideWithValue(files),
        mediaDownloaderProvider.overrideWithValue(downloader),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  const detail = TitleDetail(
    id: 'title-1',
    slug: 'show',
    name: 'Show',
    kind: 'series',
    runtimeMinutes: 50,
  );
  const episode = Episode(
    id: 'ep-1',
    number: 2,
    seasonNumber: 1,
    name: 'Episode 2',
    runtimeMinutes: 47,
  );

  test('start persists metadata and marks the download completed', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = DownloadStore(prefs);
    final files = _FakeFileStore();
    final container = await buildContainer(
      store: store,
      files: files,
      downloader: _CompletingDownloader(),
    );

    final controller = container.read(downloadsControllerProvider.notifier);
    final started = await controller.start(
      detail: detail,
      episode: episode,
      profileId: 'profile-1',
    );

    expect(started, isNotNull);
    await pumpEventQueue();

    final items = container.read(downloadsControllerProvider);
    expect(items, hasLength(1));
    final item = items.single;
    expect(item.status, DownloadStatus.completed);
    expect(item.titleId, 'title-1');
    expect(item.episode?.id, 'ep-1');
    expect(item.filePath, '/downloads/file-title-1.mp4');
    expect(item.percent, 100);
    expect(item.profileId, 'profile-1');
    expect(controller.completedFor('title-1', 'ep-1'), isNotNull);
    expect(controller.completedFor('title-1', null), isNull);

    final persisted = store.load();
    expect(persisted.single.status, DownloadStatus.completed);
    expect(persisted.single.receivedBytes, 2048);
  });

  test('cancel removes the row and deletes the partial file', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final files = _FakeFileStore();
    final container = await buildContainer(
      store: DownloadStore(prefs),
      files: files,
      downloader: _PendingDownloader(),
    );

    final controller = container.read(downloadsControllerProvider.notifier);
    await controller.start(
      detail: detail,
      episode: episode,
      profileId: 'profile-1',
    );
    expect(container.read(downloadsControllerProvider), hasLength(1));

    await controller.cancel(buildDownloadId('title-1', 'ep-1'));

    expect(container.read(downloadsControllerProvider), isEmpty);
    expect(files.deleted, contains('/downloads/file-title-1.mp4'));
  });

  test('restore drops interrupted and orphaned downloads', () async {
    final orphan = DownloadItem(
      titleId: 'missing',
      titleName: 'Missing',
      filePath: '/downloads/missing.mp4',
      createdAt: DateTime.utc(2026),
      status: DownloadStatus.completed,
    );
    final interrupted = DownloadItem(
      titleId: 'partial',
      titleName: 'Partial',
      filePath: '/downloads/partial.mp4',
      createdAt: DateTime.utc(2026),
    );
    final failed = DownloadItem(
      titleId: 'failed',
      titleName: 'Failed',
      filePath: '/downloads/failed.mp4',
      createdAt: DateTime.utc(2026),
      status: DownloadStatus.failed,
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = DownloadStore(prefs);
    await store.save([orphan, interrupted, failed]);
    final files = _FakeFileStore();

    final container = await buildContainer(
      store: store,
      files: files,
      downloader: _CompletingDownloader(),
    );
    // Build the notifier, then let its restore pass run.
    expect(container.read(downloadsControllerProvider), hasLength(3));
    await pumpEventQueue();

    final items = container.read(downloadsControllerProvider);
    expect(items.map((item) => item.titleId), ['failed']);
    expect(store.load().map((item) => item.titleId), ['failed']);
    expect(files.deleted, contains('/downloads/partial.mp4'));
  });
}
