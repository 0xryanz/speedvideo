import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The SpeedVideo wordmark. Drawn with the bundled condensed face so it
/// renders identically on every platform.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.fontSize = 26, this.color});

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'SPEEDVIDEO',
      style: TextStyle(
        fontFamily: 'BarlowCondensed',
        fontWeight: FontWeight.w900,
        fontSize: fontSize,
        letterSpacing: 0.5,
        height: 1,
        color: color ?? AppColors.red,
      ),
    );
  }
}
