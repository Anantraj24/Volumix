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
        final size = math.min(constraints.maxWidth * 0.72, 260.0);

        return GestureDetector(
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: _isDragging ? 0.28 : 0.15),
                  blurRadius: _isDragging ? 50 : 36,
                  spreadRadius: 2,
                ),
              ],
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
                        color: AppColors.cyan,
                        shadows: [
                          Shadow(
                            color: AppColors.cyan.withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MASTER',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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

  _MasterDialPainter({
    required this.percentage,
    required this.isDragging,
    required this.innerBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    final trackRadius = radius - strokeWidth / 2;

    final startAngle = 0.75 * math.pi;
    const sweepTotal = 1.5 * math.pi;
    final currentSweep = sweepTotal * (percentage / 100.0);

    final trackPaint = Paint()
      ..color = AppColors.darkSurfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: trackRadius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    if (percentage > 0) {
      final rect = Rect.fromCircle(center: center, radius: trackRadius);
      final activePaint = Paint()
        ..shader = const SweepGradient(
          colors: [AppColors.azureLight, AppColors.cyan, AppColors.cyanLight],
          startAngle: 0.75 * math.pi,
          endAngle: 2.25 * math.pi,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle,
        currentSweep,
        false,
        activePaint,
      );

      final dotAngle = startAngle + currentSweep;
      final dotX = center.dx + trackRadius * math.cos(dotAngle);
      final dotY = center.dy + trackRadius * math.sin(dotAngle);
      final dotCenter = Offset(dotX, dotY);

      final glowPaint = Paint()
        ..color = AppColors.cyan.withValues(alpha: isDragging ? 0.6 : 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, 9, glowPaint);

      final dotPaint = Paint()..color = AppColors.cyan;
      canvas.drawCircle(dotCenter, 6, dotPaint);

      final dotCorePaint = Paint()..color = Colors.white;
      canvas.drawCircle(dotCenter, 2.5, dotCorePaint);
    }

    final innerPaint = Paint()
      ..color = innerBgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth - 4, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _MasterDialPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.innerBgColor != innerBgColor;
  }
}
