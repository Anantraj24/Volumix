import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/audio_stream_types.dart';
import '../state/settings_controller.dart';
import '../state/volume_controller.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/tactile_slider.dart';

class QuickControlsScreen extends StatelessWidget {
  final VolumeController volumeController;
  final SettingsController settingsController;
  final VoidCallback onOpenSettings;

  const QuickControlsScreen({
    super.key,
    required this.volumeController,
    required this.settingsController,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final streams = volumeController.streams.where((s) => s.isSupported).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.cyan,
            size: 26,
          ),
          tooltip: 'Volumix Audio',
        ),
        title: Text(
          'Quick Controls',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(
              Icons.settings_input_component_rounded,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global Actions (Mute All / Restore All)
            QuickActionButtons(
              isAllMuted: volumeController.isAllMuted,
              hasSavedSnapshot: volumeController.hasSavedSnapshot,
              onMuteAll: volumeController.muteAll,
              onRestoreAll: volumeController.restoreAll,
            ),

            const SizedBox(height: 24),

            // Stream Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: streams.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final stream = streams[index];
                final isMuted = stream.isMuted || stream.percentage == 0;
                final primaryColor = isMuted
                    ? AppColors.mutedGrey
                    : AudioStreamTypes.getStreamPrimaryColor(stream.streamType);
                final gradient = isMuted
                    ? const LinearGradient(
                        colors: [AppColors.mutedGrey, AppColors.mutedGrey])
                    : AudioStreamTypes.getStreamSliderGradient(stream.streamType);

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header Row: Icon, Title, Subtitle, Percentage
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isMuted
                                  ? AppColors.darkSurfaceContainerHigh
                                  : primaryColor.withValues(alpha: 0.15),
                            ),
                            child: Icon(
                              AudioStreamTypes.getStreamIcon(
                                stream.streamType,
                                isMuted: isMuted,
                              ),
                              size: 22,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stream.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stream.description,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${stream.percentage}%',
                            style: AppTypography.percentage.copyWith(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Full Width Tactile Slider
                      TactileSlider(
                        value: stream.currentVolume,
                        min: stream.minVolume,
                        max: stream.maxVolume,
                        gradient: gradient,
                        onChanged: (val) {
                          volumeController.setStreamVolume(
                              stream.streamType, val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
