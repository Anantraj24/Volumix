import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/volume_stream.dart';
import '../state/settings_controller.dart';
import '../state/volume_controller.dart';
import '../widgets/master_volume_dial.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/reset_confirm_dialog.dart';
import '../widgets/status_banner.dart';
import '../widgets/tactile_stream_card.dart';

class HomeScreen extends StatelessWidget {
  final VolumeController volumeController;
  final SettingsController settingsController;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.volumeController,
    required this.settingsController,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isAmoled = settingsController.isAmoledMode;
    final streams = volumeController.streams;

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
          'Volumix',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w800,
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
      body: volumeController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // External Change Indicator
                  if (volumeController.isExternalChangeBannerVisible)
                    ExternalChangeIndicator(
                      source: volumeController.externalChangeStreamName,
                    ),

                  // DND Warning Banner if needed
                  if (!settingsController.hasDndAccess)
                    DndWarningBanner(
                      onFixInSettings: settingsController.openDndSettings,
                    ),

                  // Circular Master Volume Dial
                  const SizedBox(height: 8),
                  MasterVolumeDial(
                    percentage: volumeController.masterPercentage,
                    isAmoled: isAmoled,
                    onVolumeChanged: (pct) {
                      volumeController.setMasterVolume(pct);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Mute All / Restore All Action Buttons
                  QuickActionButtons(
                    isAllMuted: volumeController.isAllMuted,
                    hasSavedSnapshot: volumeController.hasSavedSnapshot,
                    onMuteAll: volumeController.muteAll,
                    onRestoreAll: volumeController.restoreAll,
                  ),

                  const SizedBox(height: 28),

                  // Streams Section Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Volume Streams',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // List of Granular Volume Streams
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: streams.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final stream = streams[index];
                      return TactileStreamCard(
                        stream: stream,
                        onVolumeChanged: (val) {
                          volumeController.setStreamVolume(
                              stream.streamType, val);
                        },
                        onStepMinus: () {
                          volumeController.adjustStreamVolume(
                              stream.streamType, -1);
                        },
                        onStepPlus: () {
                          volumeController.adjustStreamVolume(
                              stream.streamType, 1);
                        },
                        onToggleMute: () {
                          volumeController.toggleStreamMute(stream.streamType);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Reset All Defaults Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await ResetConfirmDialog.show(context);
                      if (confirmed == true) {
                        await volumeController.resetDefaults();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Volume preferences reset to default.'),
                              backgroundColor: AppColors.darkSurfaceContainerHigh,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
                      backgroundColor: AppColors.darkSurfaceContainerLow,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(
                      Icons.restart_alt_rounded,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    label: Text(
                      'Reset All Defaults',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
