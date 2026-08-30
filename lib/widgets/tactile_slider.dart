import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class TactileSlider extends StatefulWidget {
  final int percentage; // 0 to 100
  final LinearGradient gradient;
  final void Function(int percentage, {bool isDragging}) onPercentageChanged;
  final bool isEnabled;

  const TactileSlider({
    super.key,
    required this.percentage,
    required this.gradient,
    required this.onPercentageChanged,
    this.isEnabled = true,
  });

  @override
  State<TactileSlider> createState() => _TactileSliderState();
}

class _TactileSliderState extends State<TactileSlider> {
  bool _isDragging = false;
  double? _dragRatio; // 0.0 to 1.0

  void _handleUpdate(double localDx, double width, {required bool isDragging}) {
    if (!widget.isEnabled || width <= 0) return;
    final rawRatio = (localDx / width).clamp(0.0, 1.0);
    final pct = (rawRatio * 100.0).round().clamp(0, 100);
    final steppedRatio = pct / 100.0;

    setState(() {
      _dragRatio = steppedRatio;
    });

    widget.onPercentageChanged(pct, isDragging: isDragging);
  }

  @override
  Widget build(BuildContext context) {
    final activeRatio = (_isDragging && _dragRatio != null)
        ? _dragRatio!
        : (widget.percentage.clamp(0, 100) / 100.0);

    const double thumbWidth = 24.0;
    const double thumbHeight = 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thumbOffset = (width * activeRatio - (thumbWidth / 2))
            .clamp(0.0, width - thumbWidth);

        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (details) {
              if (!widget.isEnabled) return;
              setState(() {
                _isDragging = true;
                _dragRatio = widget.percentage / 100.0;
              });
              _handleUpdate(details.localPosition.dx, width, isDragging: true);
            },
            onHorizontalDragUpdate: (details) {
              if (!widget.isEnabled) return;
              _handleUpdate(details.localPosition.dx, width, isDragging: true);
            },
            onHorizontalDragEnd: (_) {
              if (!widget.isEnabled) return;
              final finalPct = ((_dragRatio ?? (widget.percentage / 100.0)) * 100.0)
                  .round()
                  .clamp(0, 100);
              setState(() {
                _isDragging = false;
                _dragRatio = null;
              });
              widget.onPercentageChanged(finalPct, isDragging: false);
            },
            onHorizontalDragCancel: () {
              if (!widget.isEnabled) return;
              setState(() {
                _isDragging = false;
                _dragRatio = null;
              });
            },
            onTapDown: (details) {
              if (!widget.isEnabled) return;
              _handleUpdate(details.localPosition.dx, width, isDragging: false);
            },
            child: Container(
              height: 44,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Inactive Base Track
                  Container(
                    height: 8,
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 0.5,
                      ),
                    ),
                  ),

                  // Active Filled Gradient Track
                  if (activeRatio > 0 && widget.isEnabled)
                    Container(
                      height: 8,
                      width: width * activeRatio,
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                  // Tactile Thumb Knob / Button (Accurate 1% position)
                  if (widget.isEnabled)
                    Positioned(
                      left: thumbOffset,
                      child: Container(
                        width: thumbWidth,
                        height: thumbHeight,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDragging
                              ? Colors.white
                              : widget.gradient.colors.first,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isDragging
                                ? widget.gradient.colors.first
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
