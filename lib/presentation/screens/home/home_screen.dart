import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../../data/models/listing.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../search/search_screen.dart';
import '../listing/listing_detail_screen.dart';

/// Home Screen - Main landing page with hero section and featured listings
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // Scroll listener for future use (e.g., app bar hide/show)
    });
    // Load featured listings on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredListingsProvider);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section
          SliverToBoxAdapter(child: _buildHeroSection()),

          // Trust Badges
          SliverToBoxAdapter(child: _buildTrustBadges()),

          // Statistics Section - Show real stats or loading
          SliverToBoxAdapter(
            child: featuredState.listings.isNotEmpty
                ? _buildRealStatistics(featuredState)
                : _buildPlaceholderStatistics(),
          ),

          // Quick Filters
          SliverToBoxAdapter(child: _buildQuickFilters()),

          // Featured Listings Header
          SliverToBoxAdapter(child: _buildFeaturedHeader()),

          // Featured Listings - Loading, Error, or Data
          if (featuredState.isLoading)
            const SliverToBoxAdapter(child: _FeaturedLoadingSkeleton())
          else if (featuredState.errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: WaveErrorBanner(
                  message: featuredState.errorMessage!,
                  onRetry: () {
                    ref
                        .read(featuredListingsProvider.notifier)
                        .loadFeaturedListings();
                  },
                ),
              ),
            )
          else if (featuredState.listings.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: WaveEmptyState(
                  icon: Icons.home_outlined,
                  title: 'No Featured Listings Yet',
                  subtitle: 'Browse all listings to find great properties',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertyListingCard(
                      listing: featuredState.listings[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(
                              listingId: featuredState.listings[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  childCount: featuredState.listings.length,
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

                  // Search Bar - Now navigates to SearchScreen
                  _buildSearchBar(),
                  const SizedBox(height: 16),

                  // Quick Filter Buttons - Now navigate to SearchScreen with filters
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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.wave500,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search by location...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.navy400,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navy950,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
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
          onTap: () => _navigateToSearchWithFilter(
            type: 'house',
            listingType: 'sale',
          ),
        ),
        _buildFilterChip(
          icon: Icons.landscape,
          label: 'Buy Land',
          color: AppColors.emerald500,
          onTap: () => _navigateToSearchWithFilter(
            type: 'land',
            listingType: 'sale',
          ),
        ),
        _buildFilterChip(
          icon: Icons.key,
          label: 'Rent',
          color: Colors.white.withOpacity(0.15),
          textColor: Colors.white,
          onTap: () => _navigateToSearchWithFilter(
            listingType: 'rental',
          ),
        ),
      ],
    );
  }

  void _navigateToSearchWithFilter({String? type, String? listingType}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          initialType: type,
          initialListingType: listingType,
        ),
      ),
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

  /// Placeholder statistics (shown while loading)
  Widget _buildPlaceholderStatistics() {
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
                  value: '...',
                  label: 'Active Listings',
                  suffix: 'Loading...',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.apartment,
                  iconBgColor: AppColors.wave500,
                  value: '...',
                  label: 'Houses',
                  suffix: 'Loading...',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Real statistics from featured listings
  Widget _buildRealStatistics(ListingsState state) {
    final houseCount = state.listings
        .where((l) => l.propertyType == PropertyType.house)
        .length;
    final landCount = state.listings
        .where((l) => l.propertyType == PropertyType.land)
        .length;

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
                  value: '${state.total}+',
                  label: 'Active Listings',
                  suffix: 'Growing Daily',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.apartment,
                  iconBgColor: AppColors.wave500,
                  value: '$houseCount',
                  label: 'Houses',
                  suffix: landCount > 0 ? '$landCount Lands' : 'Loading...',
                ),
              ),
            ],
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
    final state = ref.watch(featuredListingsProvider);
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
                state.listings.isNotEmpty
                    ? '${state.listings.length} properties'
                    : 'Handpicked properties just for you',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
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

/// Skeleton loading for featured listings
class _FeaturedLoadingSkeleton extends StatelessWidget {
  const _FeaturedLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.zinc100,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
