import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class TactileSlider extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final LinearGradient gradient;
  final ValueChanged<int> onChanged;
  final bool isEnabled;

  const TactileSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.gradient,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<TactileSlider> createState() => _TactileSliderState();
}

class _TactileSliderState extends State<TactileSlider> {
  bool _isDragging = false;

  void _handleUpdate(double localDx, double width) {
    if (!widget.isEnabled || width <= 0) return;
    final normalized = (localDx / width).clamp(0.0, 1.0);
    final range = widget.max - widget.min;
    final calculated = widget.min + (normalized * range).round();
    final clamped = calculated.clamp(widget.min, widget.max);

    if (clamped != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = widget.max - widget.min;
    final ratio = range > 0
        ? ((widget.value - widget.min) / range).clamp(0.0, 1.0)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragStart: (details) {
            if (!widget.isEnabled) return;
            setState(() => _isDragging = true);
            _handleUpdate(details.localPosition.dx, width);
          },
          onHorizontalDragUpdate: (details) {
            if (!widget.isEnabled) return;
            _handleUpdate(details.localPosition.dx, width);
          },
          onHorizontalDragEnd: (_) {
            if (!widget.isEnabled) return;
            setState(() => _isDragging = false);
          },
          onTapDown: (details) {
            if (!widget.isEnabled) return;
            _handleUpdate(details.localPosition.dx, width);
          },
          child: Container(
            height: 48,
            color: Colors.transparent, // expand touch target to minimum 48dp
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                // Inactive Background Track
                Container(
                  height: 10,
                  width: width,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceContainer,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                // Active Filled Gradient Track
                if (ratio > 0 && widget.isEnabled)
                  Container(
                    height: 10,
                    width: width * ratio,
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradient.colors.last.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),

                // Thumb Knob
                if (widget.isEnabled)
                  Positioned(
                    left: (width * ratio - 12).clamp(0.0, width - 24),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.gradient.colors.last,
                        border: Border.all(
                          color: AppColors.amoledBackground,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient.colors.last.withValues(alpha: _isDragging ? 0.6 : 0.3),
                            blurRadius: _isDragging ? 12 : 6,
                            spreadRadius: _isDragging ? 2 : 1,
                          ),
                        ],
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
}
