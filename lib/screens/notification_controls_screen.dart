import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/notification_settings.dart';
import '../state/settings_controller.dart';

class NotificationControlsScreen extends StatefulWidget {
  final SettingsController settingsController;

  const NotificationControlsScreen({
    super.key,
    required this.settingsController,
  });

  @override
  State<NotificationControlsScreen> createState() =>
      _NotificationControlsScreenState();
}

class _NotificationControlsScreenState
    extends State<NotificationControlsScreen> {
  late NotificationSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settingsController.notificationSettings;
  }

  void _updateSettings(NotificationSettings newSettings) {
    setState(() {
      _currentSettings = newSettings;
    });
    widget.settingsController.updateNotificationSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.cyan),
        ),
        title: Text(
          'Notification Controls',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Appearance Preview
                _buildSectionHeader('Live Notification Preview'),
                _buildNotificationPreviewCard(),

                const SizedBox(height: 24),

                // Section: Volume Streams
                _buildSectionHeader('Notification Volume Streams'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildToggleTile(
                        title: 'Show Media',
                        icon: Icons.music_note_rounded,
                        value: _currentSettings.showMedia,
                        onChanged: (val) {
                          _updateSettings(_currentSettings.copyWith(showMedia: val));
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildToggleTile(
                        title: 'Show Ring',
                        icon: Icons.notifications_active_rounded,
                        value: _currentSettings.showRing,
                        onChanged: (val) {
                          _updateSettings(_currentSettings.copyWith(showRing: val));
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildToggleTile(
                        title: 'Show Alarm',
                        icon: Icons.alarm_rounded,
                        value: _currentSettings.showAlarm,
                        onChanged: (val) {
                          _updateSettings(_currentSettings.copyWith(showAlarm: val));
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildToggleTile(
                        title: 'Show Call',
                        icon: Icons.phone_in_talk_rounded,
                        value: _currentSettings.showCall,
                        onChanged: (val) {
                          _updateSettings(_currentSettings.copyWith(showCall: val));
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section: Control Options
                _buildSectionHeader('Control Options'),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildToggleTile(
                        title: 'Show Percentage',
                        icon: Icons.percent_rounded,
                        value: _currentSettings.showPercentage,
                        onChanged: (val) {
                          _updateSettings(
                              _currentSettings.copyWith(showPercentage: val));
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _buildToggleTile(
                        title: 'Show Mute Button',
                        icon: Icons.volume_off_rounded,
                        value: _currentSettings.showMute,
                        onChanged: (val) {
                          _updateSettings(_currentSettings.copyWith(showMute: val));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildNotificationPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: App Icon, Volumix, Percentage Badge, -, +, Mute Action buttons
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkSurfaceContainerHigh,
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  size: 12,
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Volumix',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              if (_currentSettings.showPercentage)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.azureContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cyanDim.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note_rounded, size: 10, color: AppColors.cyan),
                      const SizedBox(width: 3),
                      Text(
                        'Media 75%',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.cyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              // Minus Button
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.remove, size: 14, color: AppColors.onSurface),
              ),
              const SizedBox(width: 4),
              // Plus Button
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, size: 14, color: AppColors.onSurface),
              ),
              if (_currentSettings.showMute) ...[
                const SizedBox(width: 4),
                // Mute Button
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.volume_off_rounded, size: 14, color: AppColors.onSurfaceVariant),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // Media Sound Scroll/Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              width: double.infinity,
              color: AppColors.darkSurfaceContainer,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.cyan, AppColors.azureLight],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStreamPreview(IconData icon, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: value ? AppColors.cyan : AppColors.onSurfaceVariant),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      activeTrackColor: AppColors.cyan,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
