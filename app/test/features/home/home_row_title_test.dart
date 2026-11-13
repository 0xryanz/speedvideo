import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/features/home/domain/home_models.dart';
import 'package:speedvideo/features/home/presentation/widgets/title_row.dart';
import 'package:speedvideo/l10n/generated/app_localizations.dart';

Future<String> localizedTitle(
  WidgetTester tester,
  String rowId,
  Locale locale,
) async {
  late String title;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          title = homeRowTitle(
            context,
            HomeRow(id: rowId, title: 'server fallback'),
          );
          return const SizedBox();
        },
      ),
    ),
  );
  return title;
}

void main() {
  testWidgets('home shelf titles follow the selected locale', (tester) async {
    expect(
      await localizedTitle(tester, 'top-10', const Locale('en')),
      'Top 10 in Your Country Today',
    );
    expect(
      await localizedTitle(tester, 'new-releases', const Locale('en')),
      'New Releases',
    );
    expect(
      await localizedTitle(tester, 'my-list', const Locale('en')),
      'My List',
    );
    expect(
      await localizedTitle(tester, 'genre-sci-fi', const Locale('en')),
      'Sci-Fi',
    );

    expect(
      await localizedTitle(tester, 'top-10', const Locale('zh')),
      '今日热门 Top 10',
    );
    expect(
      await localizedTitle(tester, 'new-releases', const Locale('zh')),
      '新片上线',
    );
    expect(await localizedTitle(tester, 'my-list', const Locale('zh')), '我的片单');
    expect(
      await localizedTitle(tester, 'genre-sci-fi', const Locale('zh')),
      '科幻',
    );
  });

  testWidgets('unknown rows keep the server title', (tester) async {
    expect(
      await localizedTitle(tester, 'genre-other', const Locale('zh')),
      'server fallback',
    );
  });
}
