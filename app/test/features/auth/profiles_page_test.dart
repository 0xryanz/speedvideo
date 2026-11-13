import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speedvideo/app/theme.dart';
import 'package:speedvideo/core/providers/infrastructure.dart';
import 'package:speedvideo/features/auth/data/auth_api.dart';
import 'package:speedvideo/features/auth/domain/auth_models.dart';
import 'package:speedvideo/features/auth/presentation/profiles_page.dart';
import 'package:speedvideo/features/auth/presentation/session_controller.dart';
import 'package:speedvideo/l10n/generated/app_localizations.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _FakeSessionController extends SessionController {
  @override
  SessionState build() => const SessionState(
    status: SessionStatus.authenticated,
    profiles: [Profile(id: 'p1', name: 'You')],
    activeProfileId: 'p1',
  );

  @override
  Future<void> refreshAccount() async {}
}

class _NicknamedSessionController extends SessionController {
  @override
  SessionState build() => const SessionState(
    status: SessionStatus.authenticated,
    user: User(id: 'u1', email: 'alex@example.com', displayName: 'Alex'),
    profiles: [Profile(id: 'p1', name: 'You')],
    activeProfileId: 'p1',
  );

  @override
  Future<void> refreshAccount() async {}
}

void main() {
  late _MockAuthApi api;

  setUp(() {
    api = _MockAuthApi();
    when(
      () => api.createProfile(
        name: any(named: 'name'),
        isKids: any(named: 'isKids'),
        avatarColor: any(named: 'avatarColor'),
      ),
    ).thenAnswer(
      (_) async => const Profile(id: 'p2', name: 'Kids', isKids: true),
    );
  });

  Widget buildPage({SessionController Function()? session}) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ProfilesPage()),
      ],
    );
    return ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith(
          session ?? _FakeSessionController.new,
        ),
        authApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp.router(
        theme: buildAppTheme(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: router,
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage Profiles'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Profile'));
    await tester.pumpAndSettle();
  }

  testWidgets('the profile picker shows the account nickname, not "You"', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildPage(session: _NicknamedSessionController.new),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('You'), findsNothing);
  });

  testWidgets('saving a new profile closes the dialog and creates it', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextField), 'Kids');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    verify(
      () => api.createProfile(
        name: 'Kids',
        isKids: false,
        avatarColor: '#E50914',
      ),
    ).called(1);
  });

  testWidgets('cancel closes the dialog without creating a profile', (
    tester,
  ) async {
    await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Save'), findsNothing);
    verifyNever(
      () => api.createProfile(
        name: any(named: 'name'),
        isKids: any(named: 'isKids'),
        avatarColor: any(named: 'avatarColor'),
      ),
    );
  });
}
