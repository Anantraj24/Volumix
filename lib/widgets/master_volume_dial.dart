import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class MasterVolumeDial extends StatefulWidget {
  final int percentage;
  final ValueChanged<int> onVolumeChanged;
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

  void _handlePanUpdate(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    // Calculate angle in radians from -PI to PI (0 is right, PI/2 is bottom, -PI/2 is top)
    double angle = math.atan2(dy, dx); // -PI to PI
    // Shift so 0 is at bottom-left (-135 deg) or standard dial orientation (135 deg to 405 deg)
    // Map -PI..PI into 0..2PI
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    // Standard dial starting from 135 deg (3*pi/4) clockwise to 45 deg (9*pi/4)
    // 270 deg total arc
    final startAngle = 0.75 * math.pi;
    final totalArc = 1.5 * math.pi;

    double relativeAngle = angle - startAngle;
    if (relativeAngle < 0) {
      relativeAngle += 2 * math.pi;
    }

    if (relativeAngle <= totalArc) {
      final pct = ((relativeAngle / totalArc) * 100).round().clamp(0, 100);
      widget.onVolumeChanged(pct);
    } else {
      // Near boundary: snap to 0 or 100
      if (relativeAngle > totalArc + (0.5 * math.pi - 0.25 * math.pi) / 2) {
        widget.onVolumeChanged(0);
      } else {
        widget.onVolumeChanged(100);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAmoled ? AppColors.amoledBackground : AppColors.darkBackground;
    final pct = widget.percentage.clamp(0, 100);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth * 0.72, 260.0);

        return GestureDetector(
          onPanStart: (details) {
            setState(() => _isDragging = true);
            _handlePanUpdate(details.localPosition, Size(size, size));
          },
          onPanUpdate: (details) {
            _handlePanUpdate(details.localPosition, Size(size, size));
          },
          onPanEnd: (_) {
            setState(() => _isDragging = false);
          },
          onTapDown: (details) {
            _handlePanUpdate(details.localPosition, Size(size, size));
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
                percentage: pct,
                isDragging: _isDragging,
                innerBgColor: bgColor,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pct%',
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

    final startAngle = 0.75 * math.pi; // 135 deg
    const sweepTotal = 1.5 * math.pi; // 270 deg
    final currentSweep = sweepTotal * (percentage / 100.0);

    // Track Background (Dark)
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

    // Active Progress Arc (Cyan Gradient)
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

      // Indicator Dot / Glow at progress tip
      final dotAngle = startAngle + currentSweep;
      final dotX = center.dx + trackRadius * math.cos(dotAngle);
      final dotY = center.dy + trackRadius * math.sin(dotAngle);
      final dotCenter = Offset(dotX, dotY);

      // Outer glow
      final glowPaint = Paint()
        ..color = AppColors.cyan.withValues(alpha: isDragging ? 0.6 : 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, 9, glowPaint);

      // Dot solid
      final dotPaint = Paint()..color = AppColors.cyan;
      canvas.drawCircle(dotCenter, 6, dotPaint);

      final dotCorePaint = Paint()..color = Colors.white;
      canvas.drawCircle(dotCenter, 2.5, dotCorePaint);
    }

    // Inner Cutout Circle for AMOLED effect
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
