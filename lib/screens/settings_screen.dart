import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../state/settings_controller.dart';
import '../state/volume_controller.dart';
import '../widgets/reset_confirm_dialog.dart';
import 'about_screen.dart';
import 'notification_controls_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController;
  final VolumeController volumeController;

  const SettingsScreen({
    super.key,
    required this.settingsController,
    required this.volumeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: GENERAL
            _buildSectionHeader('General'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Column(
                children: [
                  // Persistent Notification Toggle
                  SwitchListTile.adaptive(
                    value: settingsController.isPersistentNotificationEnabled,
                    onChanged: (val) {
                      settingsController.togglePersistentNotification(val);
                    },
                    secondary: Icon(
                      Icons.notifications_rounded,
                      color: settingsController.isPersistentNotificationEnabled
                          ? AppColors.cyan
                          : AppColors.onSurfaceVariant,
                    ),
                    title: const Text('Persistent Notification',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Keep Volumix controls accessible in the status bar',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    activeTrackColor: AppColors.cyan,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // Notification Controls Navigation
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NotificationControlsScreen(
                            settingsController: settingsController,
                          ),
                        ),
                      );
                    },
                    leading: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                    title: const Text('Notification Controls',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Customize which streams appear in the notification',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.onSurfaceVariant),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: APPEARANCE
            _buildSectionHeader('Appearance'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: SwitchListTile.adaptive(
                value: settingsController.isAmoledMode,
                onChanged: (val) {
                  settingsController.toggleAmoledMode(val);
                },
                secondary: Icon(
                  Icons.dark_mode_rounded,
                  color: settingsController.isAmoledMode
                      ? AppColors.cyan
                      : AppColors.onSurfaceVariant,
                ),
                title: const Text('AMOLED Pure Black',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Maximize battery savings on OLED displays',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                activeTrackColor: AppColors.cyan,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
            ),

            const SizedBox(height: 24),

            // Section: SYSTEM
            _buildSectionHeader('System'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Column(
                children: [
                  // Reset Volume Preferences
                  ListTile(
                    onTap: () async {
                      final confirmed = await ResetConfirmDialog.show(context);
                      if (confirmed == true) {
                        await volumeController.resetDefaults();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Volume preferences reset to system defaults.'),
                              backgroundColor: AppColors.darkSurfaceContainerHigh,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    leading: const Icon(
                      Icons.restart_alt_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Reset Volume Preferences',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Restore all volume levels to system defaults',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),

                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // About Volumix
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.onSurfaceVariant,
                    ),
                    title: const Text('About Volumix',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Version 2.4.1 (Build 842)',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.onSurfaceVariant),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.cyanDim,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
