import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_logo.dart';

/// Shared chrome for the welcome/login/signup screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.child,
    super.key,
    this.showBack = false,
  });

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackdrop()),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.isTv(context) ? 520 : 420,
                      ),
                      child: child,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 8,
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/welcome');
                            }
                          },
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                        ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: AppLogo(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.6, -0.8),
          radius: 1.4,
          colors: [Color(0xFF2B0709), AppColors.black],
          stops: [0, 0.6],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -120,
            top: 120,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x33E50914), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x221F4287), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
