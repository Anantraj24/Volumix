import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/audio_stream_types.dart';
import '../models/volume_preset.dart';
import '../state/presets_controller.dart';
import '../state/settings_controller.dart';
import '../state/volume_controller.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/tactile_slider.dart';

class QuickControlsScreen extends StatelessWidget {
  final VolumeController volumeController;
  final SettingsController settingsController;
  final PresetsController presetsController;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPresets;

  const QuickControlsScreen({
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
    return ListenableBuilder(
      listenable: volumeController,
      builder: (context, _) {
        final streams = volumeController.streams.where((s) => s.isSupported).toList();
        final builtIns = presetsController.builtInPresets;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.flash_on_rounded,
                color: AppColors.cyan,
                size: 24,
              ),
              tooltip: 'Quick Controls',
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
                  size: 22,
                ),
                tooltip: 'Settings',
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: ScrollConfiguration(
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
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
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

                      const SizedBox(height: 14),

                      // Quick Presets Row
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            for (final preset in builtIns)
                              Expanded(
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
                              ),
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
                      ),

                      const SizedBox(height: 16),

                      // Stream Cards using direct Column
                      for (int i = 0; i < streams.length; i++) ...[
                        _buildQuickStreamCard(context, streams[i]),
                        if (i < streams.length - 1) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStreamCard(BuildContext context, dynamic stream) {
    final isMuted = stream.isMuted || stream.percentage == 0;
    final primaryColor = isMuted
        ? AppColors.mutedGrey
        : AudioStreamTypes.getStreamPrimaryColor(stream.streamType);
    final gradient = isMuted
        ? const LinearGradient(
            colors: [AppColors.mutedGrey, AppColors.mutedGrey])
        : AudioStreamTypes.getStreamSliderGradient(stream.streamType);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 1.0,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          children: [
            // Header Row: Icon, Title, Subtitle, Percentage
            Row(
              children: [
                InkWell(
                  onTap: () {
                    volumeController.toggleStreamMute(stream.streamType);
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
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
                      size: 20,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                      const SizedBox(height: 1),
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

            const SizedBox(height: 8),

            // Controls Row: Minus + Slider + Plus
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    volumeController.adjustStreamVolume(stream.streamType, -1);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.darkSurfaceContainer,
                    foregroundColor: AppColors.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(34, 34),
                  ),
                  icon: const Icon(Icons.remove, size: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TactileSlider(
                    percentage: stream.percentage,
                    gradient: gradient,
                    onPercentageChanged: (pct, {bool isDragging = false}) {
                      volumeController.setStreamPercentage(
                        stream.streamType,
                        pct,
                        isDragging: isDragging,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  onPressed: () {
                    volumeController.adjustStreamVolume(stream.streamType, 1);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.darkSurfaceContainer,
                    foregroundColor: AppColors.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(34, 34),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
