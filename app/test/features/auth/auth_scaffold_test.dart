import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:speedvideo/app/theme.dart';
import 'package:speedvideo/features/auth/presentation/widgets/auth_scaffold.dart';

void main() {
  testWidgets('auth back button falls back to welcome when there is no stack', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const AuthScaffold(
            showBack: true,
            child: Text('login-form'),
          ),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const Scaffold(body: Text('welcome')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.text('login-form'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('welcome'), findsOneWidget);
  });
}
