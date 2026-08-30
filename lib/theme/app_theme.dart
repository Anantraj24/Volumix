import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getTheme({bool isAmoled = true}) {
    final bgColor = isAmoled ? AppColors.amoledBackground : AppColors.darkBackground;
    final surfaceColor = isAmoled ? AppColors.amoledSurface : AppColors.darkSurface;
    final cardColor = isAmoled ? AppColors.amoledSurfaceContainer : AppColors.cardBackground;

    final colorScheme = ColorScheme.dark(
      primary: AppColors.cyan,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.cyan,
      onPrimaryContainer: AppColors.cyanDark,
      secondary: AppColors.azureLight,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.azureContainer,
      onSecondaryContainer: const Color(0xFF00285B),
      tertiary: AppColors.violetLight,
      tertiaryContainer: AppColors.violetContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      surface: surfaceColor,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      onError: AppColors.onError,
      onErrorContainer: AppColors.onErrorContainer,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,
      colorScheme: colorScheme,
      cardColor: cardColor,
      dividerColor: AppColors.outlineVariant.withValues(alpha: 0.3),
      splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
          TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.cyan,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: AppColors.cardBorder, width: 1.0),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.onPrimary;
          }
          return AppColors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.cyan;
          }
          return AppColors.darkSurfaceContainerHigh;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.cyan,
        inactiveTrackColor: AppColors.darkSurfaceContainer,
        trackHeight: 6,
        thumbColor: AppColors.cyan,
        overlayColor: Colors.transparent,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
    );
  }
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
