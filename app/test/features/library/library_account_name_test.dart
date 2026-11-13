import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/core/widgets/profile_avatar.dart';
import 'package:speedvideo/features/auth/domain/auth_models.dart';
import 'package:speedvideo/features/auth/presentation/session_controller.dart';
import 'package:speedvideo/features/downloads/presentation/downloads_providers.dart';
import 'package:speedvideo/features/library/presentation/library_providers.dart';
import 'package:speedvideo/features/library/presentation/my_netflix_page.dart';
import 'package:speedvideo/l10n/generated/app_localizations_en.dart';
import 'package:speedvideo/l10n/generated/app_localizations_zh.dart';

import '../../helpers/test_app.dart';

class _SignedInSessionController extends SessionController {
  _SignedInSessionController({required this.nickname});

  final String nickname;

  @override
  SessionState build() {
    return SessionState(
      status: SessionStatus.authenticated,
      user: User(id: 'u1', email: 'viewer@example.com', displayName: nickname),
      profiles: const [Profile(id: 'p1', name: 'You')],
      activeProfileId: 'p1',
    );
  }
}

Widget buildLibrary(SessionController session) {
  return wrapWithApp(
    const MyNetflixPage(),
    overrides: [
      sessionControllerProvider.overrideWith(() => session),
      watchlistProvider.overrideWith((ref) async => const []),
      visibleDownloadsProvider.overrideWithValue(const []),
    ],
  );
}

void main() {
  testWidgets(
    'the library shows the account nickname, not the default profile',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLibrary(_SignedInSessionController(nickname: 'Alex')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('You'), findsNothing);
    },
  );

  testWidgets('an empty nickname falls back to the profile name', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildLibrary(_SignedInSessionController(nickname: '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('the avatar initial follows the resolved name', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const ProfileAvatar(
          profile: Profile(id: 'p1', name: 'You'),
          name: 'Alex',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('Y'), findsNothing);
  });

  test('the About copy stays product-facing', () {
    final english = AppLocalizationsEn();
    final chinese = AppLocalizationsZh();
    for (final copy in [english.aboutBody, chinese.aboutBody]) {
      expect(copy, isNotEmpty);
      for (final term in ['Flutter', 'Go', 'Dart', 'API']) {
        expect(copy.contains(term), isFalse, reason: 'copy mentions $term');
      }
    }
  });
}
