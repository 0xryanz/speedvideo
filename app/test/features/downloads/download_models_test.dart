import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/features/downloads/domain/download_models.dart';

void main() {
  const episode = DownloadEpisode(
    id: 'ep-1',
    number: 2,
    seasonNumber: 1,
    name: 'Episode 2',
    runtimeMinutes: 47,
  );

  test('DownloadItem round-trips through JSON', () {
    final item = DownloadItem(
      titleId: 'title-1',
      titleName: 'Stranger Things',
      filePath: '/downloads/stranger-things-s01e02.mp4',
      createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
      episode: episode,
      posterPath: '/static/posters/stranger-things.jpg',
      profileId: 'profile-1',
      status: DownloadStatus.completed,
      receivedBytes: 4096,
      totalBytes: 4096,
      durationSeconds: 2820,
    );

    final restored = DownloadItem.fromJson(item.toJson());

    expect(restored.id, 'title-1:ep-1');
    expect(restored.titleName, 'Stranger Things');
    expect(restored.episode?.code, 'S1:E2');
    expect(restored.status, DownloadStatus.completed);
    expect(restored.percent, 100);
    expect(restored.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
  });

  test('percent is clamped for unknown and partial totals', () {
    final item = DownloadItem(
      titleId: 't',
      titleName: 'T',
      filePath: '/tmp/t.mp4',
      createdAt: DateTime.utc(2026),
    );
    expect(item.percent, 0);

    final partial = item.copyWith(receivedBytes: 150, totalBytes: 200);
    expect(partial.percent, 75);
  });

  test('findDownload matches movies and exact episodes only', () {
    final movie = DownloadItem(
      titleId: 'title-1',
      titleName: 'Inception',
      filePath: '/tmp/inception.mp4',
      createdAt: DateTime.utc(2026),
    );
    final episodeDownload = DownloadItem(
      titleId: 'title-2',
      titleName: 'Show',
      filePath: '/tmp/show.mp4',
      createdAt: DateTime.utc(2026),
      episode: episode,
    );
    final items = [movie, episodeDownload];

    expect(findDownload(items, 'title-1', null)?.titleName, 'Inception');
    expect(findDownload(items, 'title-2', 'ep-1')?.titleName, 'Show');
    expect(findDownload(items, 'title-2', null), isNull);
    expect(findDownload(items, 'title-2', 'other'), isNull);
  });
}
