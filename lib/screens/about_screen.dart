import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.cyan),
        ),
        title: Text(
          'About Volumix',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon & Identity
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icons/app_icon.png',
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.cyan, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.graphic_eq_rounded,
                      size: 42,
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Volumix',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                'Version 1.0.0 (Build 1)',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.cyanDim,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'High-performance offline Android system-volume controller built with Flutter and native Kotlin Android APIs.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // Features Grid
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Core Capabilities',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.cyanDim,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.tune_rounded,
                    title: 'Hardware Sync',
                    subtitle: 'Real-time sync with physical buttons',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.notifications_active_rounded,
                    title: 'Persistent Control',
                    subtitle: 'Notification bar widgets & actions',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _buildFeatureCardWide(
              icon: Icons.shield_rounded,
              title: '100% Offline & Private',
              subtitle:
                  'Zero internet access, no trackers, and local-only hardware audio adjustments.',
            ),

            const SizedBox(height: 28),

            // Legal Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Legal & Open Source',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.cyanDim,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 1),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => _showPrivacyDialog(context),
                    leading: const Icon(Icons.policy_rounded,
                        color: AppColors.onSurfaceVariant),
                    title: const Text('Privacy Policy',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.onSurfaceVariant),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Volumix',
                        applicationVersion: '2.4.1',
                        applicationIcon: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.graphic_eq_rounded,
                              color: AppColors.cyan, size: 48),
                        ),
                      );
                    },
                    leading: const Icon(Icons.code_rounded,
                        color: AppColors.onSurfaceVariant),
                    title: const Text('Open Source Licenses',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.onSurfaceVariant),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              '© 2026 Volumix. All rights reserved.',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cyan, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCardWide({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkSurfaceContainerHigh,
            ),
            child: Icon(icon, color: AppColors.cyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const SingleChildScrollView(
          child: Text(
            'Volumix is completely offline. It does not collect, transmit, store on servers, or share any personal data, analytics, device identifiers, or audio content. All volume operations occur locally on-device through Android system APIs.',
            style: TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.cyan),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
