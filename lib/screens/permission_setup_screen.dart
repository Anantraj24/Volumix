import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../state/settings_controller.dart';

class PermissionSetupScreen extends StatelessWidget {
  final SettingsController settingsController;
  final VoidCallback onFinished;

  const PermissionSetupScreen({
    super.key,
    required this.settingsController,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.amoledBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),

              // Center Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Icon Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cyan.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        size: 54,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Headline
                  Text(
                    'Persistent Controls',
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  Text(
                    'Keep Volumix controls accessible directly from your notification panel, even when your phone is locked or other apps are running.',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Bottom Actions: Enable & Not Now
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enable Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await settingsController.requestNotificationPermission();
                        await settingsController.togglePersistentNotification(true);
                        await settingsController.completeFirstRun();
                        onFinished();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        shadowColor: AppColors.cyan.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        'Enable Notification',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Not Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () async {
                        await settingsController.completeFirstRun();
                        onFinished();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.cyan,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'Not Now',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyan,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
