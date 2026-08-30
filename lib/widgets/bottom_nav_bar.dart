import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final bool isAmoled;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.isAmoled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isAmoled
        ? AppColors.amoledSurfaceContainerLowest
        : AppColors.darkSurfaceContainerLowest;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => _handleTap(0),
              ),
              _NavItem(
                icon: Icons.tune_rounded,
                label: 'Presets',
                isSelected: currentIndex == 1,
                onTap: () => _handleTap(1),
              ),
              _NavItem(
                icon: Icons.flash_on_rounded,
                label: 'Quick',
                isSelected: currentIndex == 2,
                onTap: () => _handleTap(2),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: currentIndex == 3,
                onTap: () => _handleTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    if (currentIndex != index) {
      onTabSelected(index);
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.cyan : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.cyan : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
