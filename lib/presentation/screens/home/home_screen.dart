import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import '../search/search_screen.dart';
import '../listing/listing_detail_screen.dart';

/// Mobile-first Home Screen
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
    _loadListings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    await ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
  }

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredListingsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadListings,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Compact app bar
            SliverToBoxAdapter(child: _buildAppBar()),

            if (featuredState.isLoading && featuredState.listings.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _CardSkeleton(),
                    ),
                    childCount: 3,
                  ),
                ),
              )
            else if (featuredState.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: _buildErrorView(featuredState.errorMessage!),
                ),
              )
            else if (featuredState.listings.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState())
            else
              _buildListingsList(featuredState),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: const BoxDecoration(
        gradient: AppColors.gradientNavy,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'WaveMart',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white, size: 24),
                onPressed: () => _openSearch(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          GestureDetector(
            onTap: _openSearch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.wave500, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Search by city, region, or property type...',
                      style: TextStyle(color: AppColors.navy400, fontSize: 14),
                    ),
                  ),
                  Icon(Icons.tune, color: AppColors.navy600, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Column(
      children: [
        Icon(
          Icons.signal_wifi_off_rounded,
          size: 64,
          color: AppColors.navy300,
        ),
        const SizedBox(height: 16),
        Text(
          'Could not load listings',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadListings,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy950,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListingsList(ListingsState state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Latest Listings', style: AppTextStyles.title),
                    Text(
                      '${state.listings.length} properties',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              );
            }
            final listingIndex = index - 1;
            if (listingIndex >= state.listings.length) return null;
            final listing = state.listings[listingIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PropertyListingCard(
                listing: listing,
                onTap: () => _openListing(listing.id),
              ),
            );
          },
          childCount: state.listings.length + 1,
        ),
      ),
    );
  }

  void _openSearch() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));

  void _openListing(int id) => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: id)));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
      child: Column(
        children: [
          Icon(Icons.home_outlined, size: 64, color: AppColors.navy300),
          const SizedBox(height: 16),
          Text('No Listings Yet', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'New listings will appear here soon',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.zinc200,
      highlightColor: AppColors.zinc50,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
      child: Column(
        children: [
          Icon(Icons.home_outlined, size: 64, color: AppColors.navy300),
          const SizedBox(height: 16),
          Text('No Listings Yet', style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            'New listings will appear here soon',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
