import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure.dart';
import '../../auth/presentation/session_controller.dart';

/// Recent search queries for the active profile, persisted on device.
class RecentSearchesController extends Notifier<List<String>> {
  static const _maxEntries = 8;

  @override
  List<String> build() {
    final profileId = ref.watch(
      sessionControllerProvider.select((session) => session.activeProfileId),
    );
    if (profileId == null) return const [];
    return ref.read(sharedPreferencesProvider).getStringList(_key(profileId)) ??
        const [];
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    final profileId = ref.read(sessionControllerProvider).activeProfileId;
    if (profileId == null) return;
    final next = <String>[
      trimmed,
      ...state.where(
        (entry) => entry.toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(_maxEntries).toList(growable: false);
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(_key(profileId), next);
  }

  Future<void> clear() async {
    final profileId = ref.read(sessionControllerProvider).activeProfileId;
    if (profileId == null) return;
    state = const [];
    await ref.read(sharedPreferencesProvider).remove(_key(profileId));
  }

  String _key(String profileId) => 'speedvideo.recent_searches.$profileId';
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesController, List<String>>(
      RecentSearchesController.new,
    );
