import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class DndWarningBanner extends StatelessWidget {
  final VoidCallback onFixInSettings;

  const DndWarningBanner({
    super.key,
    required this.onFixInSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.errorContainer,
            ),
            child: const Icon(
              Icons.gpp_bad_rounded,
              color: AppColors.onErrorContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DND Access Required',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Modify Ring or Alarm while Do Not Disturb is active.',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onFixInSettings,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.darkSurfaceContainerHigh,
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: const Text('Fix', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class ExternalChangeIndicator extends StatelessWidget {
  final String source;

  const ExternalChangeIndicator({
    super.key,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.violetContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.violetContainer.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sync_rounded,
            size: 18,
            color: AppColors.violetContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Synchronized with $source',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.violetContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
