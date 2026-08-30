import 'package:flutter/material.dart';
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

  void _handlePointerUpdate(double localDx, double width, {required bool isDragging}) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (details) {
              if (!widget.isEnabled) return;
              setState(() {
                _isDragging = true;
                _dragRatio = widget.percentage / 100.0;
              });
              _handlePointerUpdate(details.localPosition.dx, width, isDragging: true);
            },
            onHorizontalDragUpdate: (details) {
              if (!widget.isEnabled) return;
              _handlePointerUpdate(details.localPosition.dx, width, isDragging: true);
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
              _handlePointerUpdate(details.localPosition.dx, width, isDragging: false);
            },
            child: SizedBox(
              height: 44,
              width: width,
              child: CustomPaint(
                size: Size(width, 44),
                painter: _TactileSliderPainter(
                  ratio: activeRatio,
                  gradient: widget.gradient,
                  isEnabled: widget.isEnabled,
                  isDragging: _isDragging,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TactileSliderPainter extends CustomPainter {
  final double ratio; // 0.0 to 1.0
  final LinearGradient gradient;
  final bool isEnabled;
  final bool isDragging;

  _TactileSliderPainter({
    required this.ratio,
    required this.gradient,
    required this.isEnabled,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double trackHeight = 8.0;
    const double thumbRadius = 11.5;
    final double trackY = (size.height - trackHeight) / 2.0;
    final double width = size.width;

    // 1. Draw Inactive Base Track
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, trackY, width, trackHeight),
      const Radius.circular(4.0),
    );
    final bgPaint = Paint()
      ..color = AppColors.darkSurfaceContainer
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trackRect, bgPaint);

    final borderPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRRect(trackRect, borderPaint);

    // 2. Draw Active Filled Gradient Track
    if (ratio > 0 && isEnabled) {
      final activeWidth = width * ratio;
      final activeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, trackY, activeWidth, trackHeight),
        const Radius.circular(4.0),
      );
      final gradientPaint = Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, trackY, width, trackHeight))
        ..style = PaintingStyle.fill;
      canvas.drawRRect(activeRect, gradientPaint);
    }

    // 3. Draw Tactile Thumb Knob Button
    if (isEnabled) {
      final double thumbCenterX =
          (width * ratio).clamp(thumbRadius, width - thumbRadius);
      final double thumbCenterY = size.height / 2.0;
      final center = Offset(thumbCenterX, thumbCenterY);

      // Outer Thumb Body
      final thumbBodyPaint = Paint()
        ..color = isDragging ? Colors.white : gradient.colors.first
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, thumbRadius, thumbBodyPaint);

      // Outer Crisp Ring
      final thumbRingPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(center, thumbRadius, thumbRingPaint);

      // Inner Core Tactile Dot
      final innerDotPaint = Paint()
        ..color = isDragging ? gradient.colors.first : Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.5, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TactileSliderPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.isEnabled != isEnabled ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.gradient != gradient;
  }
}
