import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/app/theme.dart';
import 'package:speedvideo/features/catalog/domain/catalog_models.dart';
import 'package:speedvideo/features/catalog/presentation/widgets/title_poster.dart';

void main() {
  testWidgets('TitlePoster falls back gracefully and reports taps', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(
            child: TitlePoster(
              title: const TitleCard(
                id: 't1',
                slug: 'inception',
                name: 'Inception',
                posterPath: '',
              ),
              width: 120,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('I'), findsOneWidget);
    await tester.tap(find.text('I'));
    expect(tapped, isTrue);
  });

  testWidgets('TitlePoster renders progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Center(
            child: TitlePoster(
              title: const TitleCard(
                id: 't1',
                slug: 'dune',
                name: 'Dune',
                posterPath: '',
                progress: TitleProgress(
                  positionSeconds: 300,
                  durationSeconds: 1000,
                  percent: 30,
                ),
              ),
              width: 120,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(FractionallySizedBox), findsOneWidget);
  });
}
