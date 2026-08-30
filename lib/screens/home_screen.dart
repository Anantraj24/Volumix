import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/volume_preset.dart';
import '../state/presets_controller.dart';
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
  final PresetsController presetsController;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPresets;

  const HomeScreen({
    super.key,
    required this.volumeController,
    required this.settingsController,
    required this.presetsController,
    required this.onOpenSettings,
    required this.onOpenPresets,
  });

  void _applyQuickPreset(BuildContext context, VolumePreset preset) async {
    await presetsController.applyPreset(preset);
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${preset.name} preset applied'),
          backgroundColor: AppColors.darkSurfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAmoled = settingsController.isAmoledMode;

    return ListenableBuilder(
      listenable: volumeController,
      builder: (context, _) {
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
                        onVolumeChanged: (pct, {bool isDragging = false}) {
                          volumeController.setMasterVolume(pct, isDragging: isDragging);
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

                      const SizedBox(height: 20),

                      // Quick Presets Bar
                      _buildQuickPresetsBar(context),

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
                            onVolumeChanged: (val, {bool isDragging = false}) {
                              volumeController.setStreamVolume(
                                stream.streamType,
                                val,
                                isDragging: isDragging,
                              );
                            },
                            onStepMinus: () {
                              volumeController.adjustStreamVolume(
                                stream.streamType,
                                -1,
                              );
                            },
                            onStepPlus: () {
                              volumeController.adjustStreamVolume(
                                stream.streamType,
                                1,
                              );
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
      },
    );
  }

  Widget _buildQuickPresetsBar(BuildContext context) {
    final builtIns = presetsController.builtInPresets;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ...builtIns.map((preset) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _applyQuickPreset(context, preset),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        preset.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenPresets,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.azureContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: AppColors.cyan,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
