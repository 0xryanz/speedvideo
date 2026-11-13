import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/device/tv_mode.dart';
import '../core/settings/locale_controller.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class SpeedVideoApp extends ConsumerWidget {
  const SpeedVideoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    final isTv = ref.watch(tvModeProvider);
    return TvScope(
      isTv: isTv,
      child: MaterialApp.router(
        title: 'SpeedVideo',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          if (!isTv) return child!;
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(1.08),
              padding: media.padding.copyWith(
                left: media.padding.left + 12,
                top: media.padding.top + 8,
                right: media.padding.right + 12,
                bottom: media.padding.bottom + 8,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
