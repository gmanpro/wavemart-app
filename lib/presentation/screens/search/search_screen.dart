import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Search Screen with filters - Wired to listingsProvider
class SearchScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? initialListingType;

  const SearchScreen({
    super.key,
    this.initialType,
    this.initialListingType,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedType;
  String? _selectedListingType;
  String? _selectedSort;
  Map<String, dynamic> _activeFilters = {};
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedListingType = widget.initialListingType;

    // If initial filters are provided, load listings
    if (widget.initialType != null || widget.initialListingType != null) {
      _activeFilters = {};
      if (_selectedType != null) _activeFilters['type'] = _selectedType;
      if (_selectedListingType != null) {
        _activeFilters['listing_type'] = _selectedListingType;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(listingsProvider.notifier)
            .loadListings(filters: _activeFilters);
      });
      _hasSearched = true;
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(listingsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref
          .read(listingsProvider.notifier)
          .loadListings(page: state.currentPage + 1, filters: _activeFilters);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    _activeFilters = {};
    if (query.isNotEmpty) _activeFilters['location'] = query;
    if (_selectedType != null) _activeFilters['type'] = _selectedType;
    if (_selectedListingType != null) {
      _activeFilters['listing_type'] = _selectedListingType;
    }
    if (_selectedSort != null) _activeFilters['sort'] = _selectedSort;

    setState(() {
      _hasSearched = true;
    });

    ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedListingType = null;
      _selectedSort = null;
      _activeFilters = {};
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      if (filters['type'] != null) _selectedType = filters['type'];
      if (filters['listing_type'] != null) {
        _selectedListingType = filters['listing_type'];
      }
      _hasSearched = true;
    });
    ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Active Filters
          if (_activeFilters.isNotEmpty) _buildActiveFilters(),

          // Results
          Expanded(
            child: _buildResults(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search location, property type...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _performSearch,
            icon: const Icon(Icons.filter_list),
            label: const Text('Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy950,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_activeFilters['location'] != null)
              _buildFilterChip(
                _activeFilters['location']!,
                Icons.location_on,
                () => _removeFilter('location'),
              ),
            if (_activeFilters['type'] != null)
              _buildFilterChip(
                _activeFilters['type'] == 'house' ? 'House' : 'Land',
                Icons.home,
                () => _removeFilter('type'),
              ),
            if (_activeFilters['listing_type'] != null)
              _buildFilterChip(
                _activeFilters['listing_type'] == 'sale' ? 'Sale' : 'Rent',
                Icons.attach_money,
                () => _removeFilter('listing_type'),
              ),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navy50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.navy200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close, size: 14, color: AppColors.navy600),
                    const SizedBox(width: 4),
                    Text(
                      'Clear All',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.navy700,
                        fontWeight: FontWeight.w600,
                      ),
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

  void _removeFilter(String key) {
    setState(() {
      _activeFilters.remove(key);
      if (key == 'type') _selectedType = null;
      if (key == 'listing_type') _selectedListingType = null;
    });
    ref
        .read(listingsProvider.notifier)
        .loadListings(filters: _activeFilters);
  }

  Widget _buildFilterChip(
      String label, IconData icon, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.wave50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.wave200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.wave600),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.wave700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.wave600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ListingsState state) {
    // Loading state
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.errorMessage != null) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
        },
      );
    }

    // Empty state
    if (state.listings.isEmpty && _hasSearched) {
      return WaveEmptyState(
        icon: Icons.search_off,
        title: 'No Properties Found',
        subtitle: 'Try adjusting your search or filters',
        actionLabel: 'Clear Filters',
        onAction: _clearFilters,
      );
    }

    // Initial state (no search yet)
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.navy300,
            ),
            const SizedBox(height: 16),
            Text(
              'Start searching for properties',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.navy500,
              ),
            ),
          ],
        ),
      );
    }

    // Results list
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Results Count & Sort
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.total} Properties Found',
                  style: AppTextStyles.bodyMedium,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() => _selectedSort = value);
                    _activeFilters['sort'] = value;
                    ref
                        .read(listingsProvider.notifier)
                        .loadListings(filters: _activeFilters);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Newest First'),
                    ),
                    const PopupMenuItem(
                      value: 'price_low',
                      child: Text('Price: Low to High'),
                    ),
                    const PopupMenuItem(
                      value: 'price_high',
                      child: Text('Price: High to Low'),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedSort == null
                            ? 'Sort'
                            : _selectedSort == 'newest'
                                ? 'Newest'
                                : _selectedSort == 'price_low'
                                    ? 'Price ↑'
                                    : 'Price ↓',
                        style: AppTextStyles.labelMedium,
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Listings
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= state.listings.length) {
                  // Loading more indicator
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyListingCard(
                    listing: state.listings[index],
                  ),
                );
              },
              childCount: state.hasMore
                  ? state.listings.length + 1
                  : state.listings.length,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        currentFilters: _activeFilters,
        onApply: _applyFilters,
      ),
    );
  }
}

/// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApply;

  const _FilterBottomSheet({
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.zinc300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppTextStyles.title),
                TextButton(
                  onPressed: () {
                    setState(() => _filters = {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Filter Options
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterSection(
                  title: 'Property Type',
                  children: [
                    _buildRadioTile('type', 'All Types', null),
                    _buildRadioTile('type', 'House', 'house'),
                    _buildRadioTile('type', 'Land', 'land'),
                  ],
                ),
                const SizedBox(height: 24),
                _buildFilterSection(
                  title: 'Listing Type',
                  children: [
                    _buildRadioTile('listing_type', 'All', null),
                    _buildRadioTile('listing_type', 'Sale', 'sale'),
                    _buildRadioTile('listing_type', 'Rent', 'rental'),
                  ],
                ),
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onApply(_filters),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy950,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelLarge),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildRadioTile(String key, String label, String? value) {
    final currentValue = _filters[key];

    return ListTile(
      title: Text(label),
      leading: Radio<String?>(
        value: value,
        groupValue: currentValue,
        onChanged: (v) {
          setState(() {
            if (v == null) {
              _filters.remove(key);
            } else {
              _filters[key] = v;
            }
          });
        },
        activeColor: AppColors.wave500,
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        setState(() {
          if (value == null) {
            _filters.remove(key);
          } else {
            _filters[key] = value;
          }
        });
      },
    );
  }
}
