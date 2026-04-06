import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../search/search_screen.dart';
import '../listing/listing_detail_screen.dart';

/// Home Screen - Redesigned with Header, Search, and Nav integration
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
    final authState = ref.watch(authStateProvider);
    final featuredState = ref.watch(featuredListingsProvider);
    final userFirstName = authState.user?.firstName ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1. Sticky Top Header with Profile, Greeting, and Search
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: _buildTopHeader(userFirstName),
            ),
          ),

          // 2. Section Header
          SliverToBoxAdapter(child: _buildSectionHeader("Latest Listings")),

          // 4. Content
          if (featuredState.isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (int i = 0; i < 3; i++)
                    const PropertyListingCard(isLoading: true),
                ]),
              ),
            )
          else if (featuredState.listings.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text("No listings available")),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final listing = featuredState.listings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PropertyListingCard(
                        listing: listing,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ListingDetailScreen(listingId: listing.id),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: featuredState.listings.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy950,
            AppColors.navy900,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Profile Row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navy700,
                      border: Border.all(color: AppColors.navy600, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  // Greeting
                  Expanded(
                    child: Text(
                      "Hi, $name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Notification Bell
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navy800,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.navy700),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.navy800.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.navy700),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: Colors.white70, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        ),
                        child: Text(
                          "Search City or Region...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 24,
                      color: AppColors.navy700,
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: Open filter modal
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.navy700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: AppTextStyles.title.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Sticky header delegate for persistent header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 160; // Approximate header height

  @override
  double get minExtent => 160;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
