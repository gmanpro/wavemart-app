import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../auth/otp_login_screen.dart';

/// Listing Detail Screen
class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingDetailProvider.notifier).loadListing(widget.listingId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailProvider);
    final authState = ref.watch(authStateProvider);
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? WaveErrorBanner(
                  message: state.errorMessage!,
                  onRetry: () {
                    ref
                        .read(listingDetailProvider.notifier)
                        .loadListing(widget.listingId);
                  },
                )
              : state.listing == null
                  ? _buildNotFound()
                  : _buildContent(state.listing!, favoritesState, authState),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Details')),
      body: WaveEmptyState(
        icon: Icons.home_outlined,
        title: 'Listing Not Found',
        subtitle: 'This property may have been removed',
        actionLabel: 'Back to Home',
        onAction: () => Navigator.of(context).pushReplacementNamed('/home'),
      ),
    );
  }

  Widget _buildContent(
    Listing listing,
    FavoritesState favState,
    dynamic authState,
  ) {
    final isFavorited = favState.favorites.any((f) => f.id == listing.id);

    return CustomScrollView(
      slivers: [
        // Image Gallery Sliver
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(listing),
          ),
          actions: [
            // Favorite button
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : Colors.white,
              ),
              onPressed: () => _toggleFavorite(listing.id, isFavorited),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _shareListing(listing),
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price & Title
                _buildPriceAndTitle(listing),
                const SizedBox(height: 16),

                // Badges
                _buildBadges(listing),
                const SizedBox(height: 8),

                // Location
                _buildLocation(listing),
                const Divider(height: 32),

                // Key Features
                _buildKeyFeatures(listing),
                const SizedBox(height: 24),

                // Description
                _buildDescription(listing),
                const SizedBox(height: 24),

                // Property Details
                _buildPropertyDetails(listing),
                const SizedBox(height: 24),

                // Bottom padding for action buttons
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery(Listing listing) {
    if (listing.images.isEmpty) {
      return Container(
        color: AppColors.navy100,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: AppColors.navy400),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: listing.images.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: listing.images[index].imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.navy100,
                highlightColor: AppColors.navy50,
                child: Container(color: AppColors.navy100),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.navy100,
                child: const Icon(Icons.broken_image, size: 64),
              ),
            );
          },
        ),
        // Image counter
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${listing.images.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndTitle(dynamic listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.displayPrice ?? 'Price on request',
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.emerald600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          listing.title ?? '${listing.propertyType.name} in ${listing.address?.region ?? 'Unknown'}',
          style: AppTextStyles.headline4,
        ),
      ],
    );
  }

  Widget _buildBadges(dynamic listing) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          listing.propertyType.name.toUpperCase(),
          AppColors.navy900,
        ),
        if (listing.listingType.name == 'sale')
          _buildBadge('FOR SALE', AppColors.emerald600)
        else
          _buildBadge('FOR RENT', AppColors.wave600),
        if (listing.isFeatured)
          _buildBadge('FEATURED', AppColors.wave500),
        if (listing.isNew)
          _buildBadge('NEW', Colors.amber[700]!),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLocation(dynamic listing) {
    final location = [
      listing.address?.zone,
      listing.address?.woreda,
      listing.address?.region,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: AppColors.wave500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location.isNotEmpty ? location : 'Location not specified',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.navy600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures(dynamic listing) {
    final features = <Widget>[];

    if (listing.totalSquareMeters != null) {
      features.add(_buildFeatureChip(
        icon: Icons.square_foot,
        label: '${listing.totalSquareMeters!.toStringAsFixed(0)} m²',
      ));
    }

    // Add more feature chips as needed
    if (listing.facingDirection != null) {
      features.add(_buildFeatureChip(
        icon: Icons.compass_calibration,
        label: listing.facingDirection!,
      ));
    }

    if (listing.holdingType != null) {
      features.add(_buildFeatureChip(
        icon: Icons.folder_copy,
        label: listing.holdingType!,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Features', style: AppTextStyles.title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.isNotEmpty
              ? features
              : [Text('No key features specified', style: AppTextStyles.caption)],
        ),
      ],
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.navy600),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.navy700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(dynamic listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.title),
        const SizedBox(height: 8),
        Text(
          listing.description ?? 'No description provided.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.navy700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetails(dynamic listing) {
    final details = <Map<String, String>>[];

    if (listing.useType != null) {
      details.add({'label': 'Use Type', 'value': listing.useType!});
    }
    if (listing.priceRevisionPossible) {
      details.add({'label': 'Price', 'value': 'Negotiable'});
    }
    if (listing.hasDebtOrEncumbrance) {
      details.add({'label': 'Encumbrance', 'value': 'Yes'});
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Property Details', style: AppTextStyles.title),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.zinc200),
          ),
          child: Column(
            children: details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          detail['label']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.navy500,
                          ),
                        ),
                        Text(
                          detail['value']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < details.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(int listingId, bool isFavorited) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
        );
      }
      return;
    }

    final success = await ref
        .read(favoritesProvider.notifier)
        .toggleFavorite(listingId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorited ? 'Removed from favorites' : 'Added to favorites',
          ),
          backgroundColor: success ? AppColors.wave500 : AppColors.error,
        ),
      );
    }
  }

  void _shareListing(dynamic listing) {
    // TODO: Implement sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }
}
