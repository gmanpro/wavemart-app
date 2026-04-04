import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../auth/otp_login_screen.dart';
import '../notifications/notifications_screen.dart';
import '../messages/messages_screen.dart';

/// Profile Screen - Wired to profileProvider + authStateProvider
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    ref.watch(authStateProvider); // Watch auth state for future use

    // Load profile on build
    if (profileState.isLoading && profileState.user == null) {
      ref.read(profileProvider.notifier).loadProfile();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          _buildProfileHeader(context, ref, profileState),
          const SizedBox(height: 24),

          // Stats - Show real stats or placeholders
          _buildStatsRow(profileState),
          const SizedBox(height: 24),

          // Menu Items
          _buildMenuSection(
            title: 'My Account',
            items: [
              _MenuItemData(
                icon: Icons.list_alt_outlined,
                title: 'My Listings',
                subtitle: 'Manage your properties',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('My Listings coming soon')),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.payment_outlined,
                title: 'Subscriptions',
                subtitle: 'View your plans',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscriptions coming soon')),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.receipt_long_outlined,
                title: 'Payment History',
                subtitle: 'Transaction history',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payments coming soon')),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.verified_user_outlined,
                title: 'KYC Verification',
                subtitle: profileState.user?.isKycVerified == true
                    ? 'Verified'
                    : 'Required',
                badge: profileState.user?.isKycVerified == true ? null : 'Required',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('KYC coming soon')),
                  );
                },
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MessagesScreen(),
                    ),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Stay updated',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help Center coming soon')),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.support_agent,
                title: 'Contact Support',
                subtitle: 'Get in touch',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support coming soon')),
                  );
                },
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language settings coming soon')),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy coming soon')),
                  );
                },
              ),
              _MenuItemData(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms coming soon')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
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

  Widget _buildProfileHeader(
      BuildContext context, WidgetRef ref, ProfileState state) {
    if (state.isLoading) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(profileProvider.notifier).loadProfile();
        },
      );
    }

    final user = state.user;
    if (user == null) {
      return const WaveEmptyState(
        icon: Icons.person_outline,
        title: 'Not Logged In',
        subtitle: 'Please log in to view your profile',
      );
    }

    final initials = user.initials.isNotEmpty ? user.initials : '?';
    final displayName = user.fullName.isNotEmpty ? user.fullName : 'User';
    final phoneOrEmail = user.phoneNumber.isNotEmpty
        ? user.phoneNumber
        : user.email ?? 'No contact info';

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.wave500,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
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
                displayName,
                style: AppTextStyles.title,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                phoneOrEmail,
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (user.isPhoneVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.emerald600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.emerald700,
                          letterSpacing: 0.5,
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(ProfileState state) {
    final stats = state.stats;

    return Row(
      children: [
        _buildStatItem(
          value: stats?.totalListings.toString() ?? '-',
          label: 'Listings',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          value: stats?.unreadMessages.toString() ?? '-',
          label: 'Messages',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          value: stats?.totalFavorites.toString() ?? '-',
          label: 'Favorites',
        ),
      ],
    );
  }

  Widget _buildStatItem({required String value, required String label}) {
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
              return _buildMenuItem(item,
                  showDivider: index < items.length - 1);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
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
