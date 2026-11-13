import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/core/device/tv_mode.dart';
import 'package:speedvideo/features/catalog/domain/catalog_models.dart';
import 'package:speedvideo/features/catalog/presentation/widgets/title_poster.dart';

void main() {
  testWidgets('D-pad moves focus between posters and select opens one', (
    tester,
  ) async {
    final tapped = <String>[];
    const first = TitleCard(id: '1', slug: 'one', name: 'One');
    const second = TitleCard(id: '2', slug: 'two', name: 'Two');

    await tester.pumpWidget(
      TvScope(
        isTv: true,
        child: MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitlePoster(
                    title: first,
                    autofocus: true,
                    onTap: () => tapped.add('one'),
                  ),
                  const SizedBox(width: 12),
                  TitlePoster(
                    title: second,
                    onTap: () => tapped.add('two'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(tapped, ['two']);
  });

  testWidgets('Enter also activates a focused poster', (tester) async {
    var activated = false;
    const card = TitleCard(id: '1', slug: 'one', name: 'One');

    await tester.pumpWidget(
      TvScope(
        isTv: true,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: TitlePoster(
                title: card,
                autofocus: true,
                onTap: () => activated = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(activated, isTrue);
  });
}
