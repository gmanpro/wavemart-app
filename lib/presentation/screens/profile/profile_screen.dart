import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// Profile Screen - User profile and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          _buildProfileHeader(),
          const SizedBox(height: 24),

          // Stats
          _buildStatsRow(),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuSection(
            title: 'My Account',
            items: [
              _MenuItemData(
                icon: Icons.list_alt_outlined,
                title: 'My Listings',
                subtitle: 'Manage your properties',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.payment_outlined,
                title: 'Subscriptions',
                subtitle: 'View your plans',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.receipt_long_outlined,
                title: 'Payment History',
                subtitle: 'Transaction history',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.verified_user_outlined,
                title: 'KYC Verification',
                subtitle: 'Verify your identity',
                badge: 'Required',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMenuSection(
            title: 'Communication',
            items: [
              _MenuItemData(
                icon: Icons.message_outlined,
                title: 'Messages',
                subtitle: 'Your conversations',
                badge: '3',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Stay updated',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMenuSection(
            title: 'Support',
            items: [
              _MenuItemData(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'FAQs and guides',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.support_agent,
                title: 'Contact Support',
                subtitle: 'Get in touch',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMenuSection(
            title: 'Settings',
            items: [
              _MenuItemData(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _MenuItemData(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.wave500,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: Text(
              'JD',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 4),
              Text(
                '+251912345678',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 12,
                      color: AppColors.emerald600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.emerald700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem('3', 'Listings'),
        const SizedBox(width: 16),
        _buildStatItem('1', 'Active Plan'),
        const SizedBox(width: 16),
        _buildStatItem('5', 'Favorites'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.zinc200),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.wave600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.zinc500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.zinc200),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildMenuItem(item, showDivider: index < items.length - 1);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItemData item, {bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.navy50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: AppColors.navy600,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: item.subtitle != null
              ? Text(item.subtitle!, style: AppTextStyles.caption)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.wave100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.wave700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right,
                color: AppColors.zinc400,
              ),
            ],
          ),
          onTap: item.onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    required this.onTap,
  });
}
