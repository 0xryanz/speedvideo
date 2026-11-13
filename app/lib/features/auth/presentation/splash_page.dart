import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/app_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(fontSize: 44),
            const SizedBox(height: 22),
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.red.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
