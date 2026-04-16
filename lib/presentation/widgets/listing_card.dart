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
  final bool isTogglingFavorite;
  final bool isLoading;
  final bool hideFavoriteButton;

  const PropertyListingCard({
    super.key,
    this.listing,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
    this.isLoading = false,
    this.hideFavoriteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeleton();

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

                  // Description
                  _buildDescription(),
                  const SizedBox(height: 8),

                  // Location
                  _buildLocation(),
                  const SizedBox(height: 6),

                  // Date Posted
                  _buildDatePosted(),
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

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc200),
        boxShadow: AppColors.shadowMd,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.home_rounded,
                        size: 40, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price skeleton
                  Container(
                    height: 22,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title skeleton
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Description line 1
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description line 2
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location skeleton
                  Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Date posted
                  Container(
                    height: 12,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Features skeleton (3 chips for house)
                  Row(
                    children: [
                      _skeletonChip(55),
                      const SizedBox(width: 8),
                      _skeletonChip(55),
                      const SizedBox(width: 8),
                      _skeletonChip(45),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonChip(double width) {
    return Container(
      height: 22,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(11),
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
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.home_rounded,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.navy100,
                child: const Icon(
                  Icons.home_outlined,
                  size: 64,
                  color: AppColors.navy300,
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
        if (!hideFavoriteButton)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: isTogglingFavorite ? null : onFavorite,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.red.withOpacity(0.9)
                      : Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: isTogglingFavorite
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: Colors.white,
                      ),
              ),
            ),
          ),

        // Image Count Badge
        if ((listing?.imageCount ?? 0) > 1)
          Positioned(
            top: 12,
            right: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${listing?.imageCount ?? 0}',
                    style:
                        AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ],
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

  Widget _buildDescription() {
    final description = listing?.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      description,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.zinc600),
      maxLines: 2,
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

  Widget _buildDatePosted() {
    final date = listing?.createdAt;
    if (date == null) return const SizedBox.shrink();
    final daysOld = DateTime.now().difference(date).inDays;
    String dateText;
    if (daysOld == 0) {
      dateText = 'Today';
    } else if (daysOld == 1) {
      dateText = 'Yesterday';
    } else if (daysOld < 7) {
      dateText = '$daysOld days ago';
    } else if (daysOld < 30) {
      dateText = '${(daysOld / 7).floor()} weeks ago';
    } else {
      dateText = '${(daysOld / 30).floor()} months ago';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 12, color: AppColors.zinc400),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: AppTextStyles.caption.copyWith(color: AppColors.zinc500),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final isHouse = listing?.propertyType == PropertyType.house;
    return Row(
      children: [
        // For houses: bedrooms, bathrooms, salons
        if (isHouse) ...[
          if ((listing?.bedrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bed_outlined, '${listing?.bedrooms}'),
          if ((listing?.bathrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bathtub_outlined, '${listing?.bathrooms}'),
          if ((listing?.salons ?? 0) > 0)
            _buildFeatureChip(Icons.weekend_outlined, '${listing?.salons}'),
        ] else ...[
          // For land: square meters
          _buildFeatureChip(
            Icons.square_foot_outlined,
            '${listing?.totalSquareMeters?.toInt() ?? 0} m²',
          ),
        ],
        const SizedBox(width: 8),
        _buildFeatureChip(
          Icons.sell_outlined,
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

/// Featured Listing Card - Horizontal layout with image on the left
/// Designed for the home screen featured section with modern elegant styling
class FeaturedListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final bool isTogglingFavorite;
  final bool isLoading;

  const FeaturedListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.isTogglingFavorite = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeleton();

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section (Left)
            _buildImageSection(),

            // Content Section (Right)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges Row
                    _buildBadgesRow(),
                    const SizedBox(height: 8),

                    // Price
                    _buildPrice(),
                    const SizedBox(height: 4),

                    // Description
                    _buildDescription(),
                    const SizedBox(height: 4),

                    // Location
                    _buildLocation(),
                    const SizedBox(height: 4),

                    // Date Posted
                    _buildDatePosted(),
                    const Spacer(),

                    // Features Row
                    _buildFeatures(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: SizedBox(
        width: 130,
        height: double.infinity,
        child: Stack(
          children: [
            // Main Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: listing.mainImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.home_rounded,
                      size: 32,
                      color: AppColors.navy300,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.navy100,
                  child: const Icon(
                    Icons.home_outlined,
                    size: 36,
                    color: AppColors.navy300,
                  ),
                ),
              ),
            ),

            // Favorite Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: isTogglingFavorite ? null : onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? Colors.red.withOpacity(0.85)
                        : Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: isTogglingFavorite
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    return Row(
      children: [
        // Property Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.navy950,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                listing.propertyType == PropertyType.house
                    ? Icons.home
                    : Icons.landscape,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 3),
              Text(
                listing.propertyType == PropertyType.house ? 'House' : 'Land',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (listing.isNew) _buildBadge('NEW', AppColors.emerald500),
        if (listing.isNew && listing.isFeatured) const SizedBox(width: 4),
        if (listing.isFeatured) _buildBadge('FEATURED', AppColors.wave500),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildPrice() {
    return Text(
      listing.displayPrice,
      style: AppTextStyles.priceMedium.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTitle() {
    return Text(
      listing.title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    final description = listing.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      description,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 11,
        color: AppColors.zinc600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDatePosted() {
    final date = listing.createdAt;
    final daysOld = DateTime.now().difference(date).inDays;
    String dateText;
    if (daysOld == 0) {
      dateText = 'Today';
    } else if (daysOld == 1) {
      dateText = 'Yesterday';
    } else if (daysOld < 7) {
      dateText = '$daysOld days ago';
    } else if (daysOld < 30) {
      dateText = '${(daysOld / 7).floor()} weeks ago';
    } else {
      dateText = '${(daysOld / 30).floor()} months ago';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 10, color: AppColors.zinc400),
        const SizedBox(width: 3),
        Text(
          dateText,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            color: AppColors.zinc500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 12,
          color: AppColors.wave500,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            listing.address?.shortAddress ??
                listing.address?.region ??
                'Unknown Location',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final isHouse = listing.propertyType == PropertyType.house;
    return Row(
      children: [
        if (isHouse) ...[
          if ((listing.bedrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bed_outlined, '${listing.bedrooms}'),
          if ((listing.bathrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bathtub_outlined, '${listing.bathrooms}'),
        ] else ...[
          _buildFeatureChip(
            Icons.square_foot_outlined,
            '${listing.totalSquareMeters?.toInt() ?? 0} m²',
          ),
        ],
        const SizedBox(width: 4),
        _buildFeatureChip(
          Icons.sell_outlined,
          listing.listingType == ListingType.sale ? 'Sale' : 'Rent',
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.navy400),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc200),
        boxShadow: AppColors.shadowMd,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton (left, fixed width)
            Container(
              width: 130,
              height: 120,
              color: Colors.grey[300],
            ),
            // Content skeleton (right)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 60,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Container(
                      height: 18,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description line
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Date posted
                    Container(
                      height: 10,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Features (2 chips)
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 40,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
