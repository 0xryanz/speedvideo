import 'package:flutter/material.dart';

/// Brand palette and spacing tokens shared by every screen.
abstract final class AppColors {
  static const black = Color(0xFF000000);
  static const background = Color(0xFF0B0B0B);
  static const surface = Color(0xFF181818);
  static const surfaceElevated = Color(0xFF232323);
  static const red = Color(0xFFE50914);
  static const redDark = Color(0xFFB20710);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textTertiary = Color(0xFF7A7A7A);
  static const outline = Color(0xFF333333);
  static const success = Color(0xFF46D369);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Focus/hover overlay for remote controls and keyboards. Material's default
/// focus tint is too subtle at TV viewing distance.
WidgetStateProperty<Color?> _focusOverlay(Color color) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.focused)) return color;
    if (states.contains(WidgetState.hovered)) {
      return color.withValues(alpha: color.a * 0.35);
    }
    return null;
  });
}

/// Netflix-adjacent visual language: black canvas, red accents, condensed
/// display type and quiet surfaces.
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme =
      TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: 56,
          height: 0.95,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: 44,
          height: 1,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        displaySmall: const TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: const TextStyle(
          fontFamily: 'BarlowCondensed',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 16,
          height: 1.35,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 14,
          height: 1.35,
        ),
        bodySmall: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelMedium: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'Barlow',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );

  const scheme = ColorScheme.dark(
    primary: AppColors.red,
    onPrimary: AppColors.textPrimary,
    primaryContainer: AppColors.redDark,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
    onSecondary: AppColors.black,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceElevated,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    error: Color(0xFFFF5A5F),
    onError: AppColors.textPrimary,
    shadow: AppColors.black,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.black,
    canvasColor: AppColors.black,
    focusColor: AppColors.red.withValues(alpha: 0.4),
    hoverColor: AppColors.red.withValues(alpha: 0.12),
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
      titleTextStyle: textTheme.titleLarge,
      systemOverlayStyle: null,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
      ).copyWith(overlayColor: _focusOverlay(Colors.white)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        textStyle: textTheme.labelLarge,
      ).copyWith(overlayColor: _focusOverlay(AppColors.red)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.outline),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: textTheme.labelLarge,
      ).copyWith(overlayColor: _focusOverlay(AppColors.red)),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        focusColor: AppColors.red.withValues(alpha: 0.5),
        hoverColor: AppColors.red.withValues(alpha: 0.2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.textSecondary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: scheme.error),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.outline,
      thickness: 0.6,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.background.withValues(alpha: 0.98),
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      height: 64,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          color: selected ? AppColors.textPrimary : AppColors.textTertiary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 10,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.textPrimary : AppColors.textTertiary,
          size: 24,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: textTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.red,
      linearTrackColor: AppColors.outline,
      circularTrackColor: AppColors.outline,
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.red,
      inactiveTrackColor: AppColors.outline,
      thumbColor: AppColors.red,
      overlayColor: Color(0x33E50914),
      trackHeight: 3,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.textPrimary,
      secondarySelectedColor: AppColors.textPrimary,
      side: const BorderSide(color: AppColors.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: AppColors.black,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textPrimary,
      textColor: AppColors.textPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.red,
      labelStyle: textTheme.titleSmall,
      unselectedLabelStyle: textTheme.titleSmall,
      dividerColor: AppColors.outline,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
