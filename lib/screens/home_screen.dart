import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/volume_preset.dart';
import '../state/presets_controller.dart';
import '../state/settings_controller.dart';
import '../state/volume_controller.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.cyan,
            size: 24,
          ),
          tooltip: 'Volumix Audio',
        ),
        title: Text(
          'Volumix',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(
              Icons.settings_input_component_rounded,
              color: AppColors.onSurfaceVariant,
              size: 22,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: volumeController,
        builder: (context, _) {
          if (volumeController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.cyan,
                strokeWidth: 2.5,
              ),
            );
          }

          final streams = volumeController.streams;

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Mute All / Restore All Action Buttons
                  QuickActionButtons(
                    isAllMuted: volumeController.isAllMuted,
                    hasSavedSnapshot: volumeController.hasSavedSnapshot,
                    onMuteAll: volumeController.muteAll,
                    onRestoreAll: volumeController.restoreAll,
                  ),

                  const SizedBox(height: 12),

                  // Quick Presets Bar
                  _buildQuickPresetsBar(context),

                  const SizedBox(height: 18),

                  // Streams Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Volume Streams',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${streams.where((s) => s.isSupported).length} active',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.cyanDim,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Direct Column of Granular Volume Streams
                  for (int i = 0; i < streams.length; i++) ...[
                    TactileStreamCard(
                      stream: streams[i],
                      onVolumeChanged: (val, {bool isDragging = false}) {
                        volumeController.setStreamVolume(
                          streams[i].streamType,
                          val,
                          isDragging: isDragging,
                        );
                      },
                      onStepMinus: () {
                        volumeController.adjustStreamVolume(
                          streams[i].streamType,
                          -1,
                        );
                      },
                      onStepPlus: () {
                        volumeController.adjustStreamVolume(
                          streams[i].streamType,
                          1,
                        );
                      },
                      onToggleMute: () {
                        volumeController.toggleStreamMute(streams[i].streamType);
                      },
                    ),
                    if (i < streams.length - 1) const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 20),

                  // Reset All Defaults Button
                  Center(
                    child: OutlinedButton.icon(
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
                        side: const BorderSide(color: AppColors.cardBorder, width: 1.0),
                        backgroundColor: AppColors.darkSurfaceContainerLow,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      label: Text(
                        'Reset All Defaults',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickPresetsBar(BuildContext context) {
    final builtIns = presetsController.builtInPresets;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          ...builtIns.map((preset) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _applyQuickPreset(context, preset),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        preset.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onOpenPresets,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.azureContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 15,
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
