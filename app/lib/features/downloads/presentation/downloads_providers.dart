import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/session_controller.dart';
import '../domain/download_models.dart';
import 'downloads_controller.dart';

/// Downloads visible to the active profile, newest first.
final visibleDownloadsProvider = Provider<List<DownloadItem>>((ref) {
  final profileId = ref.watch(
    sessionControllerProvider.select((session) => session.activeProfileId),
  );
  if (profileId == null) return const [];
  final items = ref.watch(downloadsControllerProvider);
  final visible =
      items.where((item) => item.profileId == profileId).toList(growable: false)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return visible;
});

/// Total bytes held by the active profile's downloads.
final downloadsSizeProvider = Provider<int>((ref) {
  return ref
      .watch(visibleDownloadsProvider)
      .fold<int>(0, (total, item) => total + item.receivedBytes);
});
