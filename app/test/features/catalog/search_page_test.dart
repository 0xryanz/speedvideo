import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedvideo/core/providers/infrastructure.dart';
import 'package:speedvideo/features/auth/domain/auth_models.dart';
import 'package:speedvideo/features/auth/presentation/session_controller.dart';
import 'package:speedvideo/features/catalog/data/catalog_api.dart';
import 'package:speedvideo/features/catalog/domain/catalog_models.dart';
import 'package:speedvideo/features/catalog/presentation/catalog_providers.dart';
import 'package:speedvideo/features/catalog/presentation/search_page.dart';
import 'package:speedvideo/features/catalog/presentation/widgets/title_poster.dart';

import '../../helpers/test_app.dart';

class _MockCatalogApi extends Mock implements CatalogApi {}

class _FakeSessionController extends SessionController {
  @override
  SessionState build() => const SessionState(
    status: SessionStatus.authenticated,
    profiles: [Profile(id: 'p1', name: 'You')],
    activeProfileId: 'p1',
  );
}

void main() {
  late _MockCatalogApi api;
  late SharedPreferences preferences;

  setUp(() async {
    api = _MockCatalogApi();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  Widget buildPage() {
    return wrapWithApp(
      const SearchPage(),
      overrides: [
        sessionControllerProvider.overrideWith(_FakeSessionController.new),
        catalogApiProvider.overrideWithValue(api),
        sharedPreferencesProvider.overrideWithValue(preferences),
        genresProvider.overrideWith(
          (ref) async => const [
            Genre(slug: 'sci-fi', name: 'Sci-Fi'),
            Genre(slug: 'drama', name: 'Drama'),
          ],
        ),
      ],
    );
  }

  testWidgets('search page shows genres without the type filter', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Sci-Fi'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);
    expect(find.text('All'), findsNothing);
    expect(find.text('Movies'), findsNothing);
    expect(find.text('TV Shows'), findsNothing);
  });

  testWidgets('typing a query searches the catalogue', (tester) async {
    when(() => api.search('dune')).thenAnswer(
      (_) async => const [
        TitleCard(id: 't1', slug: 'dune', name: 'Dune', posterPath: ''),
      ],
    );

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'dune');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    verify(() => api.search('dune')).called(1);
    expect(find.byType(TitlePoster), findsOneWidget);
  });

  testWidgets('a genre chip browses that genre', (tester) async {
    when(
      () => api.browse(
        kind: null,
        genre: 'sci-fi',
        sort: null,
        page: 1,
        pageSize: 30,
      ),
    ).thenAnswer((_) async => const BrowsePage(items: []));

    await tester.pumpWidget(buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sci-Fi'));
    await tester.pumpAndSettle();

    verify(
      () => api.browse(
        kind: null,
        genre: 'sci-fi',
        sort: null,
        page: 1,
        pageSize: 30,
      ),
    ).called(1);
    expect(find.text('No titles match these filters.'), findsOneWidget);
  });
}
