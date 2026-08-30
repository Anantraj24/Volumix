import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class MasterVolumeDial extends StatefulWidget {
  final int percentage;
  final void Function(int value, {bool isDragging}) onVolumeChanged;
  final bool isAmoled;

  const MasterVolumeDial({
    super.key,
    required this.percentage,
    required this.onVolumeChanged,
    this.isAmoled = true,
  });

  @override
  State<MasterVolumeDial> createState() => _MasterVolumeDialState();
}

class _MasterVolumeDialState extends State<MasterVolumeDial> {
  bool _isDragging = false;
  int? _localDragValue;

  void _handlePanUpdate(Offset localPos, Size size, {required bool isDragging}) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    double angle = math.atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    final startAngle = 0.75 * math.pi;
    final totalArc = 1.5 * math.pi;

    double relativeAngle = angle - startAngle;
    if (relativeAngle < 0) {
      relativeAngle += 2 * math.pi;
    }

    int pct;
    if (relativeAngle <= totalArc) {
      pct = ((relativeAngle / totalArc) * 100).round().clamp(0, 100);
    } else {
      if (relativeAngle > totalArc + (0.5 * math.pi - 0.25 * math.pi) / 2) {
        pct = 0;
      } else {
        pct = 100;
      }
    }

    if (pct != (_localDragValue ?? widget.percentage)) {
      setState(() {
        _localDragValue = pct;
      });
      widget.onVolumeChanged(pct, isDragging: isDragging);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAmoled ? AppColors.amoledBackground : AppColors.darkBackground;
    final activePct = (_isDragging && _localDragValue != null)
        ? _localDragValue!
        : widget.percentage.clamp(0, 100);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth * 0.70, 240.0);

        return RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
                _localDragValue = widget.percentage;
              });
              _handlePanUpdate(details.localPosition, Size(size, size), isDragging: true);
            },
            onPanUpdate: (details) {
              _handlePanUpdate(details.localPosition, Size(size, size), isDragging: true);
            },
            onPanEnd: (_) {
              final finalVal = _localDragValue ?? widget.percentage;
              setState(() {
                _isDragging = false;
                _localDragValue = null;
              });
              widget.onVolumeChanged(finalVal, isDragging: false);
            },
            onPanCancel: () {
              setState(() {
                _isDragging = false;
                _localDragValue = null;
              });
            },
            onTapDown: (details) {
              _handlePanUpdate(details.localPosition, Size(size, size), isDragging: false);
            },
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(
                  color: _isDragging ? AppColors.cyan : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: _MasterDialPainter(
                  percentage: activePct,
                  isDragging: _isDragging,
                  innerBgColor: bgColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$activePct%',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 48,
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MASTER',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
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
}

class _MasterDialPainter extends CustomPainter {
  final int percentage;
  final bool isDragging;
  final Color innerBgColor;

  static final Paint _trackPaint = Paint()
    ..color = AppColors.darkSurfaceContainer
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10.0
    ..strokeCap = StrokeCap.round;

  static final Paint _activePaint = Paint()
    ..color = AppColors.cyan
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10.0
    ..strokeCap = StrokeCap.round;

  static final Paint _dotPaint = Paint()
    ..color = AppColors.cyan
    ..style = PaintingStyle.fill;

  static final Paint _dotCorePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  _MasterDialPainter({
    required this.percentage,
    required this.isDragging,
    required this.innerBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;
    final trackRadius = radius - strokeWidth - 6;

    final startAngle = 0.75 * math.pi;
    const sweepTotal = 1.5 * math.pi;
    final currentSweep = sweepTotal * (percentage / 100.0);

    // Inactive track arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: trackRadius),
      startAngle,
      sweepTotal,
      false,
      _trackPaint,
    );

    // Active track arc
    if (percentage > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: trackRadius),
        startAngle,
        currentSweep,
        false,
        _activePaint,
      );

      final dotAngle = startAngle + currentSweep;
      final dotX = center.dx + trackRadius * math.cos(dotAngle);
      final dotY = center.dy + trackRadius * math.sin(dotAngle);
      final dotCenter = Offset(dotX, dotY);

      canvas.drawCircle(dotCenter, 6, _dotPaint);
      canvas.drawCircle(dotCenter, 2.5, _dotCorePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MasterDialPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.innerBgColor != innerBgColor;
  }
}
