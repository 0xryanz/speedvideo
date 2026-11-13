import 'package:flutter/widgets.dart';

import '../device/tv_mode.dart';

/// Layout tokens that scale from phone to TV without a separate UI tree.
abstract final class Responsive {
  /// Android TV is detected natively; a directional navigation mode also
  /// implies a D-pad (or keyboard) driven device, so the 10-foot layout is the
  /// right choice there too.
  static bool isTv(BuildContext context) =>
      TvScope.of(context) ||
      MediaQuery.navigationModeOf(context) == NavigationMode.directional;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  /// Overscan-safe gutter. TVs can crop 5% of each edge, so the TV layout uses
  /// a much larger gutter than a phone.
  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (isTv(context)) {
      if (width >= 1280) return 64;
      if (width >= 960) return 48;
      return 32;
    }
    if (width >= 1200) return 56;
    if (width >= 800) return 32;
    return 16;
  }

  static double posterWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (isTv(context)) {
      if (width >= 1600) return 220;
      if (width >= 1280) return 200;
      return 176;
    }
    if (width >= 1200) return 168;
    if (width >= 800) return 148;
    return 112;
  }

  static double billboardHeight(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (isTv(context)) {
      return (size.height * 0.66).clamp(300.0, 460.0);
    }
    final base = size.height * 0.62;
    return base.clamp(380.0, 720.0);
  }

  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (isTv(context)) {
      if (width >= 1600) return 8;
      if (width >= 1280) return 7;
      if (width >= 960) return 6;
      return 5;
    }
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    return 3;
  }

  /// Extra vertical room inside a poster cell for the focus ring and scale.
  static double posterCellSlack(BuildContext context) => isTv(context) ? 24 : 6;
}
