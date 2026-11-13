/// Download domain models.
///
/// Downloads are device-local: the API only issues short-lived signed
/// grants, while this layer owns the file, its progress and its metadata.
library;

/// The lifecycle of one downloaded rendition.
enum DownloadStatus { downloading, completed, failed }

/// Episode identity attached to a downloaded series episode.
class DownloadEpisode {
  const DownloadEpisode({
    required this.id,
    this.number = 0,
    this.seasonNumber = 0,
    this.name = '',
    this.runtimeMinutes = 0,
  });

  factory DownloadEpisode.fromJson(Map<String, dynamic> json) {
    return DownloadEpisode(
      id: json['id'] as String? ?? '',
      number: (json['number'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final int number;
  final int seasonNumber;
  final String name;
  final int runtimeMinutes;

  String get code => 'S$seasonNumber:E$number';

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'season_number': seasonNumber,
    'name': name,
    'runtime_minutes': runtimeMinutes,
  };
}

/// Signed grant returned by `GET /v1/downloads/{titleID}`.
class DownloadSession {
  const DownloadSession({
    required this.downloadUrl,
    required this.titleId,
    required this.fileName,
    this.expiresAt,
    this.titleName = '',
    this.episode,
    this.posterPath = '',
    this.durationSeconds = 0,
  });

  factory DownloadSession.fromJson(Map<String, dynamic> json) {
    final expiresAt = json['expires_at'] as String?;
    return DownloadSession(
      downloadUrl: json['download_url'] as String? ?? '',
      titleId: json['title_id'] as String? ?? '',
      fileName: json['file_name'] as String? ?? 'download.mp4',
      expiresAt: expiresAt == null ? null : DateTime.tryParse(expiresAt),
      titleName: json['title_name'] as String? ?? '',
      episode: json['episode'] is Map<String, dynamic>
          ? DownloadEpisode.fromJson(json['episode'] as Map<String, dynamic>)
          : null,
      posterPath: json['poster_path'] as String? ?? '',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
    );
  }

  final String downloadUrl;
  final String titleId;
  final String fileName;
  final DateTime? expiresAt;
  final String titleName;
  final DownloadEpisode? episode;
  final String posterPath;
  final int durationSeconds;
}

/// One rendered item shown in the downloads shelf.
class DownloadItem {
  const DownloadItem({
    required this.titleId,
    required this.titleName,
    required this.filePath,
    required this.createdAt,
    this.episode,
    this.posterPath = '',
    this.profileId = '',
    this.status = DownloadStatus.downloading,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.durationSeconds = 0,
    this.error,
  });

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    final status = DownloadStatus.values.firstWhere(
      (value) => value.name == json['status'],
      orElse: () => DownloadStatus.failed,
    );
    return DownloadItem(
      titleId: json['title_id'] as String? ?? '',
      titleName: json['title_name'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      episode: json['episode'] is Map<String, dynamic>
          ? DownloadEpisode.fromJson(json['episode'] as Map<String, dynamic>)
          : null,
      posterPath: json['poster_path'] as String? ?? '',
      profileId: json['profile_id'] as String? ?? '',
      status: status,
      receivedBytes: (json['received_bytes'] as num?)?.toInt() ?? 0,
      totalBytes: (json['total_bytes'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
    );
  }

  final String titleId;
  final String titleName;
  final String filePath;
  final DateTime createdAt;
  final DownloadEpisode? episode;
  final String posterPath;
  final String profileId;
  final DownloadStatus status;
  final int receivedBytes;
  final int totalBytes;
  final int durationSeconds;
  final String? error;

  /// Stable identity: one download per title/episode rendition.
  String get id => buildDownloadId(titleId, episode?.id);

  bool get isCompleted => status == DownloadStatus.completed;
  bool get isDownloading => status == DownloadStatus.downloading;

  /// 0-100 progress, safe for ratios.
  int get percent {
    if (isCompleted) return 100;
    if (totalBytes <= 0) return 0;
    return ((receivedBytes * 100) ~/ totalBytes).clamp(0, 100);
  }

  DownloadItem copyWith({
    DownloadStatus? status,
    int? receivedBytes,
    int? totalBytes,
    int? durationSeconds,
    String? error,
    bool clearError = false,
  }) {
    return DownloadItem(
      titleId: titleId,
      titleName: titleName,
      filePath: filePath,
      createdAt: createdAt,
      episode: episode,
      posterPath: posterPath,
      profileId: profileId,
      status: status ?? this.status,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      error: clearError ? null : (error ?? this.error),
    );
  }

  Map<String, dynamic> toJson() => {
    'title_id': titleId,
    'title_name': titleName,
    'file_path': filePath,
    'created_at': createdAt.toIso8601String(),
    'episode': episode?.toJson(),
    'poster_path': posterPath,
    'profile_id': profileId,
    'status': status.name,
    'received_bytes': receivedBytes,
    'total_bytes': totalBytes,
    'duration_seconds': durationSeconds,
    'error': error,
  };
}

/// Shared identity builder so controllers and lookups cannot drift apart.
String buildDownloadId(String titleId, String? episodeId) =>
    episodeId == null ? '$titleId:movie' : '$titleId:$episodeId';

/// Finds a download for a title/episode pair regardless of its status.
DownloadItem? findDownload(
  Iterable<DownloadItem> items,
  String titleId,
  String? episodeId,
) {
  final id = buildDownloadId(titleId, episodeId);
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}
