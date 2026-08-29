import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class QuickActionButtons extends StatelessWidget {
  final bool isAllMuted;
  final bool hasSavedSnapshot;
  final VoidCallback onMuteAll;
  final VoidCallback onRestoreAll;

  const QuickActionButtons({
    super.key,
    required this.isAllMuted,
    required this.hasSavedSnapshot,
    required this.onMuteAll,
    required this.onRestoreAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mute All Button
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onMuteAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAllMuted
                    ? AppColors.darkSurfaceContainerHighest
                    : AppColors.darkSurfaceContainer,
                foregroundColor: isAllMuted ? AppColors.cyan : AppColors.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                  side: BorderSide(
                    color: isAllMuted ? AppColors.cyan : AppColors.cardBorder,
                    width: 1.2,
                  ),
                ),
              ),
              icon: Icon(
                Icons.volume_off_rounded,
                size: 20,
                color: isAllMuted ? AppColors.cyan : AppColors.onSurfaceVariant,
              ),
              label: Text(
                'Mute All',
                style: AppTypography.labelLarge.copyWith(
                  color: isAllMuted ? AppColors.cyan : AppColors.onSurface,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Restore All Button
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onRestoreAll();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSavedSnapshot
                    ? AppColors.cyan.withValues(alpha: 0.15)
                    : AppColors.darkSurfaceContainer,
                foregroundColor:
                    hasSavedSnapshot ? AppColors.cyan : AppColors.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                  side: BorderSide(
                    color: hasSavedSnapshot
                        ? AppColors.cyan
                        : AppColors.cardBorder,
                    width: 1.2,
                  ),
                ),
              ),
              icon: Icon(
                Icons.settings_backup_restore_rounded,
                size: 20,
                color: hasSavedSnapshot
                    ? AppColors.cyan
                    : AppColors.onSurfaceVariant,
              ),
              label: Text(
                'Restore All',
                style: AppTypography.labelLarge.copyWith(
                  color:
                      hasSavedSnapshot ? AppColors.cyan : AppColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
