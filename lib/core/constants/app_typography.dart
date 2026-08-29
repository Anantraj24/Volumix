import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 64 / 56,
    letterSpacing: -1.12,
    color: AppColors.cyan,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: AppColors.cyanDim,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.7,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    letterSpacing: 0.88,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle percentage = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'monospace',
    letterSpacing: 0.5,
  );
}
