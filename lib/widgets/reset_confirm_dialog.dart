import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class ResetConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirmReset;

  const ResetConfirmDialog({
    super.key,
    required this.onConfirmReset,
  });

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.amoledBackground.withValues(alpha: 0.8),
      builder: (context) => ResetConfirmDialog(
        onConfirmReset: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.errorContainer.withValues(alpha: 0.25),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.error,
                size: 26,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              'Reset Preferences?',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 22,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // Body
            Text(
              'This will reset all volume streams back to system default levels and clear your saved snapshots. This action cannot be undone.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onConfirmReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
