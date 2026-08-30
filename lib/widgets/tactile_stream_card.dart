import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/audio_stream_types.dart';
import '../models/volume_stream.dart';
import 'tactile_slider.dart';

class TactileStreamCard extends StatefulWidget {
  final VolumeStream stream;
  final void Function(int percentage, {bool isDragging}) onVolumeChanged;
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
  State<TactileStreamCard> createState() => _TactileStreamCardState();
}

class _TactileStreamCardState extends State<TactileStreamCard> {
  late final ValueNotifier<int> _percentageNotifier;

  @override
  void initState() {
    super.initState();
    _percentageNotifier = ValueNotifier<int>(widget.stream.percentage);
  }

  @override
  void didUpdateWidget(covariant TactileStreamCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream.percentage != widget.stream.percentage) {
      _percentageNotifier.value = widget.stream.percentage;
    }
  }

  @override
  void dispose() {
    _percentageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream;
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

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSupported ? AppColors.cardBorder : AppColors.darkSurfaceContainer,
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Left Accent Color Strip
            if (isSupported)
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Title + Description + Percentage Badge
                  Row(
                    children: [
                      // Icon Button
                      InkWell(
                        onTap: isSupported ? widget.onToggleMute : null,
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
                            iconData,
                            size: 20,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

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
                                    fontSize: 16,
                                    color: isSupported
                                        ? AppColors.onSurface
                                        : AppColors.outline,
                                  ),
                                ),
                                if (stream.isExternallyChanged) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.violetContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'EXT',
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
                              const SizedBox(height: 1),
                              Text(
                                isSupported
                                    ? stream.description
                                    : 'Not supported on this device',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 11,
                                  color: isSupported
                                      ? AppColors.onSurfaceVariant
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Percentage Display (Local ValueListenableBuilder for 120fps immediate update)
                      ValueListenableBuilder<int>(
                        valueListenable: _percentageNotifier,
                        builder: (context, pct, _) {
                          return Text(
                            '$pct%',
                            style: AppTypography.percentage.copyWith(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Controls Row: Minus Button + Slider + Plus Button
                  Row(
                    children: [
                      // Minus Button
                      IconButton.filledTonal(
                        onPressed: isSupported ? widget.onStepMinus : null,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.darkSurfaceContainer,
                          foregroundColor: AppColors.onSurfaceVariant,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(34, 34),
                        ),
                        icon: const Icon(Icons.remove, size: 16),
                      ),

                      const SizedBox(width: 6),

                      // Tactile Gradient Slider (Accurate 1% Slider)
                      Expanded(
                        child: TactileSlider(
                          percentage: stream.percentage,
                          gradient: sliderGradient,
                          isEnabled: isSupported,
                          onPercentageChanged: (pct, {bool isDragging = false}) {
                            _percentageNotifier.value = pct;
                            widget.onVolumeChanged(pct, isDragging: isDragging);
                          },
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Plus Button
                      IconButton.filledTonal(
                        onPressed: isSupported ? widget.onStepPlus : null,
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
          ],
        ),
      ),
    );
  }
}
