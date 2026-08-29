import 'package:flutter/material.dart';

/// Stitch Design System Color Palette for Volumix
class AppColors {
  AppColors._();

  // Primary & Accents
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDim = Color(0xFF00DAF3);
  static const Color cyanLight = Color(0xFFC3F5FF);
  static const Color cyanDark = Color(0xFF00626E);
  static const Color onPrimary = Color(0xFF00363D);

  // Secondary (Azure)
  static const Color azure = Color(0xFF007BFF);
  static const Color azureLight = Color(0xFFADC7FF);
  static const Color azureContainer = Color(0xFF4A8EFF);
  static const Color onSecondary = Color(0xFF002E68);

  // Tertiary (Violet)
  static const Color violet = Color(0xFF7C4DFF);
  static const Color violetLight = Color(0xFFF1E9FF);
  static const Color violetContainer = Color(0xFFD6C9FF);
  static const Color onTertiaryContainer = Color(0xFF622BE5);

  // Neutral / Backgrounds for Standard Dark Mode
  static const Color darkBackground = Color(0xFF131313);
  static const Color darkSurface = Color(0xFF131313);
  static const Color darkSurfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color darkSurfaceContainerLow = Color(0xFF1B1B1B);
  static const Color darkSurfaceContainer = Color(0xFF1F1F1F);
  static const Color darkSurfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color darkSurfaceContainerHighest = Color(0xFF353535);

  // Neutral / Backgrounds for Pure Black AMOLED Mode
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF000000);
  static const Color amoledSurfaceContainerLowest = Color(0xFF000000);
  static const Color amoledSurfaceContainerLow = Color(0xFF0A0A0A);
  static const Color amoledSurfaceContainer = Color(0xFF121212);
  static const Color amoledSurfaceContainerHigh = Color(0xFF1A1A1A);
  static const Color amoledSurfaceContainerHighest = Color(0xFF242424);

  // Tactile Cards
  static const Color cardBackground = Color(0xFF121212);
  static const Color cardBorder = Color(0xFF1F1F1F);
  static const Color cardBorderActive = Color(0xFF00DAF3);

  // Text & Content
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFBAC9CC);
  static const Color outline = Color(0xFF849396);
  static const Color outlineVariant = Color(0xFF3B494C);
  static const Color mutedGrey = Color(0xFF424242);

  // Error States
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onError = Color(0xFF690005);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Gradients
  static const LinearGradient masterDialGradient = LinearGradient(
    colors: [cyanDim, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mediaSliderGradient = LinearGradient(
    colors: [azureContainer, azureLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient ringSliderGradient = LinearGradient(
    colors: [cyan, cyanLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient alarmSliderGradient = LinearGradient(
    colors: [onTertiaryContainer, violetContainer],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient quickSliderGradient = LinearGradient(
    colors: [azureLight, cyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
