import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../listing/listing_detail_screen.dart';
import '../../../data/models/listing.dart';

/// Home Screen - Modern premium header with glassmorphism & animations
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _togglingFavorites = {};
  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
      ref.read(listingsProvider.notifier).loadListings();
      ref.read(authStateProvider.notifier).loadUser();
      _headerAnimationController.forward();
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
    _headerAnimationController.dispose();
    super.dispose();
  }

  bool _isFavorite(int listingId) {
    final favState = ref.read(favoritesProvider);
    return favState.favorites.any((f) => f is Listing && f.id == listingId);
  }

  Future<void> _toggleFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) setState(() => _togglingFavorites.remove(listingId));
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final featuredState = ref.watch(featuredListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);
    ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(featuredListingsProvider.notifier).loadFeaturedListings(),
            ref.read(listingsProvider.notifier).loadListings(),
            ref.read(authStateProvider.notifier).loadUser(),
          ]);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HeaderDelegate(
                authState: authState,
                unreadCountAsync: unreadCountAsync,
                onSearchTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                onProfileTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                onNotificationsTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildSectionHeader("Featured Listings"),
                      _buildFeaturedListings(featuredState),
                      _buildSectionHeader("Latest Listings"),
                    ],
                  ),
                ),
              ),
            ),
            _buildLatestListings(listingsState),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        alignItems: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyles.title.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title == 'Featured Listings' ? 'Premium properties' : 'Recently added',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.wave50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.wave200),
            ),
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.wave700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
            child: SizedBox(width: 280, child: PropertyListingCard(isLoading: true)),
          ),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return const SizedBox(height: 80, child: Center(child: Text("No featured listings available")));
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
                  MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: listing.id)),
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
            for (int i = 0; i < 3; i++) const PropertyListingCard(isLoading: true),
          ]),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text("No latest listings available")));
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
                  MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: listing.id)),
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

/// Modern Premium Header Delegate - Glassmorphism with notifications badge
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final AuthState authState;
  final AsyncValue<int> unreadCountAsync;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  _HeaderDelegate({
    required this.authState,
    required this.unreadCountAsync,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkPercent = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final user = authState.user;
    final userFirstName = user?.firstName ?? 'WaveMart';
    final userInitials = _getInitials(user?.firstName, user?.lastName);
    final isScrolled = overlapsContent ?? false;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.navy950.withOpacity(isScrolled ? 0.98 : 0.95),
                AppColors.navy900.withOpacity(isScrolled ? 0.96 : 0.90),
              ],
            ),
            boxShadow: isScrolled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: AppColors.wave500.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20, 
                12 - (4 * shrinkPercent), 
                20, 
                12 - (4 * shrinkPercent)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main header row
                  Row(
                    children: [
                      // Profile section
                      Expanded(
                        child: GestureDetector(
                          onTap: onProfileTap,
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            children: [
                              // Animated avatar with initials
                              _buildAvatar(userInitials, shrinkPercent),
                              const SizedBox(width: 12),
                              // User greeting
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 18 - (2 * shrinkPercent),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.2,
                                        height: 1.2,
                                      ),
                                      child: Text(
                                        'Hi, $userFirstName',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (shrinkPercent < 0.3)
                                      Text(
                                        'Discover your perfect property',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.65),
                                          fontWeight: FontWeight.w400,
                                          height: 1.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notifications button
                          _buildActionButton(
                            icon: Icons.notifications_outlined,
                            onTap: onNotificationsTap,
                            shrinkPercent: shrinkPercent,
                            badgeProvider: () => unreadCountAsync,
                          ),
                          const SizedBox(width: 8),
                          // Search button
                          _buildSearchButton(shrinkPercent),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String initials, double shrinkPercent) {
    final size = 48.0 - (4 * shrinkPercent);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.wave500,
            AppColors.wave600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.wave500.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 18 - (2 * shrinkPercent),
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required double shrinkPercent,
    required AsyncValue<int> Function() badgeProvider,
  }) {
    final size = 44.0 - (4 * shrinkPercent);
    final badgeValue = badgeProvider();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14 - (2 * shrinkPercent)),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22 - (2 * shrinkPercent),
            ),
          ),
          // Badge
          if (badgeValue is AsyncData && badgeValue.value! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: AppColors.wave500,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: AppColors.navy950,
                    width: 2,
                  ),
                ),
                child: Text(
                  badgeValue.value! > 99 ? '99+' : '${badgeValue.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(double shrinkPercent) {
    final size = 44.0 - (4 * shrinkPercent);

    return GestureDetector(
      onTap: onSearchTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.wave500.withOpacity(0.9),
              AppColors.wave600,
            ],
          ),
          borderRadius: BorderRadius.circular(14 - (2 * shrinkPercent)),
          boxShadow: [
            BoxShadow(
              color: AppColors.wave500.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.search_rounded,
          color: Colors.white,
          size: 22 - (2 * shrinkPercent),
        ),
      ),
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    if (firstName == null && lastName == null) return 'WM';
    final first = firstName?.substring(0, 1).toUpperCase() ?? '';
    final last = lastName?.substring(0, 1).toUpperCase() ?? '';
    return (first + last).isEmpty ? 'WM' : first + last;
  }

  @override
  double get maxExtent => 95;
  @override
  double get minExtent => 68;

  @override
  bool shouldRebuild(_HeaderDelegate oldDelegate) {
    return oldDelegate.authState != authState ||
           oldDelegate.unreadCountAsync != unreadCountAsync;
  }
}
