import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/profiles_page.dart';
import '../features/auth/presentation/session_controller.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/welcome_page.dart';
import '../features/catalog/presentation/new_hot_page.dart';
import '../features/catalog/presentation/search_page.dart';
import '../features/catalog/presentation/title_detail_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/library/presentation/my_netflix_page.dart';
import '../features/playback/presentation/player_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'shell.dart';

class _SessionRefreshNotifier extends ChangeNotifier {
  _SessionRefreshNotifier(Ref ref) {
    ref.listen<SessionState>(sessionControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SessionRefreshNotifier(ref);
  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final location = state.matchedLocation;
      final onAuthScreen =
          location == '/welcome' ||
          location == '/login' ||
          location == '/signup';

      switch (session.status) {
        case SessionStatus.initializing:
          return location == '/splash' ? null : '/splash';
        case SessionStatus.unauthenticated:
          // Guests can browse and watch. Only account-only screens are
          // redirected, and the sign-in form stays available on demand.
          if (location == '/splash') return '/home';
          if (location == '/profiles') return '/login';
          return null;
        case SessionStatus.needsProfile:
          return location == '/profiles' ? null : '/profiles';
        case SessionStatus.authenticated:
          if (location == '/splash' ||
              onAuthScreen ||
              location == '/profiles') {
            final switching = state.uri.queryParameters['switch'] == '1';
            if (switching) return null;
            return '/home';
          }
          return null;
      }
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/profiles',
        builder: (context, state) => const ProfilesPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/new',
                builder: (context, state) => const NewHotPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-netflix',
                builder: (context, state) => const MyNetflixPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/title/:id',
        builder: (context, state) => TitleDetailPage(
          titleId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/watch/:id',
        builder: (context, state) => PlayerPage(
          titleId: state.pathParameters['id']!,
          episodeId: state.uri.queryParameters['episodeId'],
          offline: state.uri.queryParameters['offline'] == '1',
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, size: 40),
            const SizedBox(height: 12),
            Text(state.error?.toString() ?? context.l10n.somethingWentWrong),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: Text(context.l10n.home),
            ),
          ],
        ),
      ),
    ),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
