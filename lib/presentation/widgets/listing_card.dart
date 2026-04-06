import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/listing.dart';

/// Property Listing Card Widget
class PropertyListingCard extends StatelessWidget {
  final Listing? listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PropertyListingCard({
    super.key,
    this.listing,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.zinc200),
          boxShadow: AppColors.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  _buildPrice(),
                  const SizedBox(height: 8),

                  // Title
                  _buildTitle(),
                  const SizedBox(height: 4),

                  // Location
                  _buildLocation(),
                  const SizedBox(height: 12),

                  // Features Row
                  _buildFeatures(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Main Image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: CachedNetworkImage(
              imageUrl: listing?.mainImageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.zinc100,
                highlightColor: AppColors.zinc50,
                child: Container(color: AppColors.zinc100),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.zinc100,
                child: const Icon(
                  Icons.home_outlined,
                  size: 64,
                  color: AppColors.zinc300,
                ),
              ),
            ),
          ),
        ),

        // Badges Overlay
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: [
              if (listing?.isNew ?? false)
                _buildBadge('NEW', AppColors.emerald500),
              if (listing?.isFeatured ?? false)
                _buildBadge('FEATURED', AppColors.wave500),
            ],
          ),
        ),

        // Favorite Button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onFavorite,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isFavorite
                    ? Colors.red.withOpacity(0.9)
                    : Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Property Type Badge
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  listing?.propertyType == PropertyType.house
                      ? Icons.home
                      : Icons.landscape,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  listing?.propertyType == PropertyType.house
                      ? 'House'
                      : 'Land',
                  style: AppTextStyles.badge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPrice() {
    final price = listing?.displayPrice ?? 'Price on Request';
    return Text(
      price,
      style: AppTextStyles.priceMedium,
    );
  }

  Widget _buildTitle() {
    return Text(
      listing?.title ?? 'Property Listing',
      style: AppTextStyles.titleSmall,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    final location = listing?.address?.shortAddress ??
        listing?.address?.region ??
        'Unknown Location';
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.wave500,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      children: [
        _buildFeatureChip(
          Icons.bed_outlined,
          '${listing?.totalSquareMeters?.toInt() ?? 0} m²',
        ),
        const SizedBox(width: 8),
        _buildFeatureChip(
          Icons.directions_car_outlined,
          listing?.listingType == ListingType.sale ? 'Sale' : 'Rent',
        ),
        const Spacer(),
        Icon(
          Icons.visibility_outlined,
          size: 16,
          color: AppColors.zinc400,
        ),
        const SizedBox(width: 4),
        Text(
          '${(DateTime.now().millisecondsSinceEpoch % 100).toInt() + 20}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.navy500),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
