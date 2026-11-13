import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedvideo/core/device/tv_mode.dart';
import 'package:speedvideo/core/utils/responsive.dart';

void main() {
  testWidgets('TvScope drives the 10-foot layout', (tester) async {
    late bool isTv;
    await tester.pumpWidget(
      TvScope(
        isTv: true,
        child: Builder(
          builder: (context) {
            isTv = Responsive.isTv(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(isTv, isTrue);
  });

  testWidgets('directional navigation also enables the TV layout', (
    tester,
  ) async {
    late bool isTv;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(navigationMode: NavigationMode.directional),
        child: TvScope(
          isTv: false,
          child: Builder(
            builder: (context) {
              isTv = Responsive.isTv(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(isTv, isTrue);
  });

  testWidgets('TV layout uses overscan-safe dimensions', (tester) async {
    late double padding;
    late double poster;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(960, 540),
          navigationMode: NavigationMode.directional,
        ),
        child: TvScope(
          isTv: true,
          child: Builder(
            builder: (context) {
              padding = Responsive.pagePadding(context);
              poster = Responsive.posterWidth(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(padding, 48);
    expect(poster, 176);
  });
}
