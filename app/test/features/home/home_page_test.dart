import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/features/auth/domain/auth_models.dart';
import 'package:speedvideo/features/auth/presentation/session_controller.dart';
import 'package:speedvideo/features/catalog/domain/catalog_models.dart';
import 'package:speedvideo/features/home/domain/home_models.dart';
import 'package:speedvideo/features/home/presentation/home_page.dart';
import 'package:speedvideo/features/home/presentation/home_providers.dart';
import 'package:speedvideo/features/library/presentation/library_providers.dart';

import '../../helpers/test_app.dart';

class _FakeSessionController extends SessionController {
  @override
  SessionState build() {
    return const SessionState(
      status: SessionStatus.authenticated,
      user: User(id: 'u1', email: 'demo@example.com'),
      profiles: [Profile(id: 'p1', name: 'You')],
      activeProfileId: 'p1',
    );
  }
}

void main() {
  const card = TitleCard(
    id: 't1',
    slug: 'inception',
    name: 'Inception',
    releaseYear: 2010,
    matchPercent: 98,
    badges: ['Top 10'],
    genres: [Genre(slug: 'sci-fi', name: 'Sci-Fi')],
  );
  const feed = HomeFeed(
    billboard: card,
    rows: [
      HomeRow(
        id: 'continue',
        title: 'Continue Watching',
        kind: 'continue',
        items: [card],
      ),
      HomeRow(
        id: 'top10',
        title: 'Top 10 in Your Country Today',
        kind: 'ranked',
        ranked: true,
        items: [card, card, card],
      ),
    ],
  );

  testWidgets('home renders billboard, continue row and top ten shelf', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithApp(
        const HomePage(),
        overrides: [
          sessionControllerProvider.overrideWith(_FakeSessionController.new),
          homeFeedProvider.overrideWith((ref) async => feed),
          watchlistProvider.overrideWith((ref) async => const <TitleCard>[]),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('INCEPTION'), findsOneWidget);
    expect(find.text('Continue Watching'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Top 10 in Your Country Today'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(find.text('2'), findsNothing);
  });
}
