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
          // 1. Top Header with Profile and Greeting
          SliverToBoxAdapter(child: _buildTopHeader(userFirstName)),

          // 2. Search Bar with Filter Button
          SliverToBoxAdapter(child: _buildSearchBar()),

          // 3. Section Header
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navy100,
              ),
              child: const Icon(Icons.person, color: AppColors.navy600, size: 28),
            ),
            const SizedBox(width: 12),
            // Greeting
            Expanded(
              child: Text(
                "Hi, $name",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Notification Bell
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.zinc200),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: AppColors.navy600, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.zinc200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search, color: AppColors.navy500, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Search City, Region, or Property...",
                        style: TextStyle(
                          color: AppColors.navy400,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.navy900,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy900.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
          ),
        ],
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
