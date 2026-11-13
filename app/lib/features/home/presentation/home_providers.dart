import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/infrastructure.dart';
import '../../auth/presentation/session_controller.dart';
import '../domain/home_models.dart';

/// Personalised home feed; refetches when the selected profile changes.
final homeFeedProvider = FutureProvider.autoDispose<HomeFeed>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.activeProfileId));
  return ref.watch(catalogApiProvider).home();
});
