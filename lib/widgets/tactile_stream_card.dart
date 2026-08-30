import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/audio_stream_types.dart';
import '../models/volume_stream.dart';
import 'tactile_slider.dart';

class TactileStreamCard extends StatelessWidget {
  final VolumeStream stream;
  final void Function(int value, {bool isDragging}) onVolumeChanged;
  final VoidCallback onStepMinus;
  final VoidCallback onStepPlus;
  final VoidCallback onToggleMute;

  const TactileStreamCard({
    super.key,
    required this.stream,
    required this.onVolumeChanged,
    required this.onStepMinus,
    required this.onStepPlus,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    final isSupported = stream.isSupported;
    final isMuted = stream.isMuted || stream.percentage == 0;

    final primaryColor = isSupported
        ? (isMuted
            ? AppColors.mutedGrey
            : AudioStreamTypes.getStreamPrimaryColor(stream.streamType))
        : AppColors.mutedGrey;

    final sliderGradient = isSupported && !isMuted
        ? AudioStreamTypes.getStreamSliderGradient(stream.streamType)
        : const LinearGradient(
            colors: [AppColors.mutedGrey, AppColors.mutedGrey],
          );

    final iconData = AudioStreamTypes.getStreamIcon(
      stream.streamType,
      isMuted: isMuted,
    );

    return Opacity(
      opacity: isSupported ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 1.0,
          ),
          boxShadow: [
            if (isSupported && !isMuted && stream.percentage > 0)
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.05),
                blurRadius: 16,
                spreadRadius: 0,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left Accent Color Strip
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: Container(
                width: 4,
                color: primaryColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Title + Description + Percentage Badge
                  Row(
                    children: [
                      // Icon Circle
                      InkWell(
                        onTap: isSupported ? onToggleMute : null,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMuted
                                ? AppColors.darkSurfaceContainerHigh
                                : primaryColor.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            iconData,
                            size: 22,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stream.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSupported
                                        ? AppColors.onSurface
                                        : AppColors.outline,
                                  ),
                                ),
                                if (stream.isExternallyChanged) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.violetContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'EXTERNAL',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (stream.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                isSupported
                                    ? stream.description
                                    : 'Not supported on this device',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isSupported
                                      ? AppColors.onSurfaceVariant
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Percentage Display
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

                  const SizedBox(height: 10),

                  // Controls Row: Minus Button + Slider + Plus Button
                  Row(
                    children: [
                      // Minus Button
                      IconButton.filledTonal(
                        onPressed: isSupported ? onStepMinus : null,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.darkSurfaceContainer,
                          foregroundColor: AppColors.onSurfaceVariant,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(38, 38),
                        ),
                        icon: const Icon(Icons.remove, size: 18),
                      ),

                      const SizedBox(width: 8),

                      // Tactile Gradient Slider
                      Expanded(
                        child: TactileSlider(
                          value: stream.currentVolume,
                          min: stream.minVolume,
                          max: stream.maxVolume,
                          gradient: sliderGradient,
                          isEnabled: isSupported,
                          onChanged: onVolumeChanged,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Plus Button
                      IconButton.filledTonal(
                        onPressed: isSupported ? onStepPlus : null,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.darkSurfaceContainer,
                          foregroundColor: AppColors.onSurfaceVariant,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(38, 38),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
