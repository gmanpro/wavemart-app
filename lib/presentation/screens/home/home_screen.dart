import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../search/search_screen.dart';
import '../listing/listing_detail_screen.dart';
import '../../../data/models/listing.dart';

/// Home Screen - Redesigned with Header, Search, and Nav integration
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _togglingFavorites = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
      ref.read(listingsProvider.notifier).loadListings();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(listingsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref.read(listingsProvider.notifier).loadListings(page: state.currentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isFavorite(int listingId) {
    final favState = ref.read(favoritesProvider);
    return favState.favorites.any(
      (f) => f is Listing && f.id == listingId,
    );
  }

  Future<void> _toggleFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    final success = await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) {
      setState(() => _togglingFavorites.remove(listingId));
    }
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final featuredState = ref.watch(featuredListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final userFirstName = authState.user?.firstName ?? 'User';
    // Watch favorites for reactive heart state
    ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(featuredListingsProvider.notifier).loadFeaturedListings(),
            ref.read(listingsProvider.notifier).loadListings(),
          ]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          // 1. Sticky Top Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: _buildTopHeader(userFirstName),
            ),
          ),

          // 2. Featured Listings Header
          SliverToBoxAdapter(child: _buildSectionHeader("Featured Listings")),

          // 3. Featured Listings
          SliverToBoxAdapter(child: _buildFeaturedListings(featuredState)),

          // 4. Latest Listings Header
          SliverToBoxAdapter(child: _buildSectionHeader("Latest Listings")),

          // 5. Latest Listings
          _buildLatestListings(listingsState),
        ],
      ),
      ),
    );
  }

  Widget _buildTopHeader(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy950, AppColors.navy900],
        ),
      ),
      child: SafeArea(
        child: Padding(
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
              // Search icon
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navy800,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.navy700),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              // Filter icon
              GestureDetector(
                onTap: () {
                  // TODO: Open filter modal
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navy800,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.navy700),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              // Notification Bell
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.navy800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.navy700),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              ),
            ],
          ),
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

  Widget _buildFeaturedListings(ListingsState state) {
    if (state.isLoading) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: PropertyListingCard(isLoading: true),
            ),
          ),
        ),
      );
    }

    if (state.listings.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text("No featured listings available")),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.listings.length,
        itemBuilder: (context, index) {
          final listing = state.listings[index];
          final fav = _isFavorite(listing.id);
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: FeaturedListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listingId: listing.id),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLatestListings(ListingsState state) {
    if (state.isLoading && state.listings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            for (int i = 0; i < 3; i++)
              const PropertyListingCard(isLoading: true),
          ]),
        ),
      );
    }

    if (state.listings.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text("No latest listings available")),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.listings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = state.listings[index];
            final fav = _isFavorite(listing.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listingId: listing.id),
                  ),
                ),
              ),
            );
          },
          childCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
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
  double get maxExtent => 100; // Approximate header height

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
