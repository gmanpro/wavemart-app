import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Home Screen - Main landing page with hero section and featured listings
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section
          SliverToBoxAdapter(child: _buildHeroSection()),

          // Trust Badges
          SliverToBoxAdapter(child: _buildTrustBadges()),

          // Statistics Section
          SliverToBoxAdapter(child: _buildStatistics()),

          // Quick Filters
          SliverToBoxAdapter(child: _buildQuickFilters()),

          // Featured Listings Header
          SliverToBoxAdapter(child: _buildFeaturedHeader()),

          // Featured Listings Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const PropertyListingCard(),
                childCount: 6,
              ),
            ),
          ),

          // Bottom padding for nav
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        gradient: AppColors.gradientHero,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Background pattern (placeholder for image)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/hero.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 32),

                  // Subtitle Badge
                  _buildSubtitleBadge(),
                  const SizedBox(height: 16),

                  // Headline
                  _buildHeadline(),
                  const SizedBox(height: 12),

                  // Subheadline
                  _buildSubheadline(),
                  const SizedBox(height: 32),

                  // Search Bar
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // Quick Filter Buttons
                  _buildQuickFilterButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.navy800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.navy700),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Wave',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
              TextSpan(
                text: 'Mart',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.wave400,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.wave400.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.wave400.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.wave400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Ethiopia\'s #1 Real Estate Platform',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.wave300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return Text(
      'Find Your Dream\nProperty in Ethiopia',
      style: AppTextStyles.headline1,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubheadline() {
    return Text(
      'Browse thousands of houses and lands for sale or rent\nwith verified listings and secure transactions',
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.navy200,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by location...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.navy400,
          ),
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: AppColors.wave500,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(4),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy950,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Search'),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildQuickFilterButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildFilterChip(
          icon: Icons.home,
          label: 'Buy House',
          color: AppColors.wave500,
          onTap: () {},
        ),
        _buildFilterChip(
          icon: Icons.landscape,
          label: 'Buy Land',
          color: AppColors.emerald500,
          onTap: () {},
        ),
        _buildFilterChip(
          icon: Icons.key,
          label: 'Rent',
          color: Colors.white.withValues(alpha: 0.15),
          textColor: Colors.white,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: color == Colors.transparent
              ? Border.all(color: Colors.white.withOpacity(0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: textColor ?? Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.buttonSmall.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustBadgeItem(
            icon: Icons.verified_outlined,
            label: 'Verified',
          ),
          _TrustBadgeItem(
            icon: Icons.security,
            label: 'Secure',
          ),
          _TrustBadgeItem(
            icon: Icons.support_agent,
            label: 'Support',
          ),
          _TrustBadgeItem(
            icon: Icons.home_work_outlined,
            label: 'Quality',
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.home_work,
                  iconBgColor: AppColors.wave500,
                  value: '2,500+',
                  label: 'Active Listings',
                  suffix: 'Growing Daily',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.apartment,
                  iconBgColor: AppColors.wave500,
                  value: '1,800+',
                  label: 'Houses',
                  suffix: 'Starting from 2M ETB',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            icon: Icons.people,
            iconBgColor: AppColors.wave500,
            value: '5,000+',
            label: 'Happy Customers',
            suffix: '4.8 ★ Average Rating',
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconBgColor,
    required String value,
    required String label,
    String? suffix,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconBgColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headline3.copyWith(
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
          ),
          if (suffix != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.emerald50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                suffix,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.emerald600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: WaveSectionHeader(
        title: 'Quick Filters',
        subtitle: 'Popular searches',
      ),
    );
  }

  Widget _buildFeaturedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Listings',
                style: AppTextStyles.title,
              ),
              Text(
                'Handpicked properties just for you',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}

class _TrustBadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadgeItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.wave50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.wave600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
