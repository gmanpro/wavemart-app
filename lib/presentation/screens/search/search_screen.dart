import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../listing/listing_detail_screen.dart';

/// Modern Search & Filter Screen
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedType; // 'house', 'land', or null for all
  String? _selectedListingType; // 'sale', 'rental', or null for all
  String _selectedSort = 'newest';
  Map<String, dynamic> _activeFilters = {};
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = ref.read(listingsProvider);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref.read(listingsProvider.notifier).loadListings(
            page: state.currentPage + 1,
            filters: _activeFilters,
          );
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
    _activeFilters['sort'] = _selectedSort;

    setState(() => _hasSearched = true);
    ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedListingType = null;
      _selectedSort = 'newest';
      _activeFilters = {};
      _hasSearched = false;
      _searchController.clear();
    });
  }

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedListingType != null ||
      _selectedSort != 'newest' ||
      _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final listingsState = ref.watch(listingsProvider);

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: Column(
        children: [
          // Search Header
          _buildSearchHeader(),

          // Filter Row
          _buildFilterRow(),

          // Active Filter Chips
          if (_hasActiveFilters) _buildActiveFilterChips(),

          // Results
          Expanded(
            child: _hasSearched
                ? _buildResults(listingsState)
                : _buildWelcomeState(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                padding: const EdgeInsets.all(8),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by location...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.navy400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.zinc50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wave500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _filterDropdown(
              label: 'Type',
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Types')),
                DropdownMenuItem(value: 'house', child: Text('🏠 House')),
                DropdownMenuItem(value: 'land', child: Text('🌄 Land')),
              ],
              onChanged: (v) {
                setState(() => _selectedType = v);
                _performSearch();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _filterDropdown(
              label: 'Status',
              value: _selectedListingType,
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'sale', child: Text('💰 For Sale')),
                DropdownMenuItem(value: 'rental', child: Text('🔑 For Rent')),
              ],
              onChanged: (v) {
                setState(() => _selectedListingType = v);
                _performSearch();
              },
            ),
          ),
          const SizedBox(width: 8),
          _sortButton(),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.zinc50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.zinc200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.zinc500)),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy800),
        ),
      ),
    );
  }

  Widget _sortButton() {
    return GestureDetector(
      onTap: () => _showSortBottomSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.zinc50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.zinc200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 18, color: AppColors.zinc600),
            const SizedBox(width: 4),
            Text(
              _getSortLabel(_selectedSort),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedType != null)
              _filterChip(
                _selectedType == 'house' ? '🏠 House' : '🌄 Land',
                () => setState(() => _selectedType = null),
              ),
            if (_selectedListingType != null)
              _filterChip(
                _selectedListingType == 'sale' ? '💰 For Sale' : '🔑 For Rent',
                () => setState(() => _selectedListingType = null),
              ),
            if (_searchController.text.isNotEmpty)
              _filterChip(
                '📍 ${_searchController.text}',
                () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.zinc300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.close, size: 14, color: AppColors.zinc600),
                    SizedBox(width: 4),
                    Text(
                      'Clear All',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.zinc600),
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

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.wave50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.wave200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.wave700),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close, size: 14, color: AppColors.wave600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: AppColors.navy200),
          const SizedBox(height: 24),
          Text(
            'Find Your Perfect Property',
            style: AppTextStyles.title.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.navy800,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Search by location, filter by type and status to discover amazing properties',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.zinc500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Popular Searches
          const Text(
            'Popular Searches',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _popularSearchChip('🏠 Houses', () => setState(() => _selectedType = 'house')),
              _popularSearchChip('🌄 Lands', () => setState(() => _selectedType = 'land')),
              _popularSearchChip('💰 For Sale', () => setState(() => _selectedListingType = 'sale')),
              _popularSearchChip('🔑 For Rent', () => setState(() => _selectedListingType = 'rental')),
              _popularSearchChip('💰 Under 5M', () {
                setState(() => _selectedListingType = null);
                _activeFilters = {'price_max': 5000000, 'sort': _selectedSort};
                _hasSearched = true;
                ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
              }),
              _popularSearchChip('💎 5M - 10M', () {
                setState(() => _selectedListingType = null);
                _activeFilters = {'price_min': 5000000, 'price_max': 10000000, 'sort': _selectedSort};
                _hasSearched = true;
                ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
              }),
              _popularSearchChip('🏆 10M - 50M', () {
                setState(() => _selectedListingType = null);
                _activeFilters = {'price_min': 10000000, 'price_max': 50000000, 'sort': _selectedSort};
                _hasSearched = true;
                ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
              }),
              _popularSearchChip('👑 50M - 100M', () {
                setState(() => _selectedListingType = null);
                _activeFilters = {'price_min': 50000000, 'price_max': 100000000, 'sort': _selectedSort};
                _hasSearched = true;
                ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
              }),
              _popularSearchChip('✨ 100M+', () {
                setState(() => _selectedListingType = null);
                _activeFilters = {'price_min': 100000000, 'sort': _selectedSort};
                _hasSearched = true;
                ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _popularSearchChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.zinc300),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy700),
        ),
      ),
    );
  }

  Widget _buildResults(ListingsState state) {
    if (state.isLoading && state.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: _performSearch,
      );
    }

    if (state.listings.isEmpty) {
      return WaveEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Properties Found',
        subtitle: 'Try adjusting your search or filters to find more results',
        actionLabel: 'Clear Filters',
        onAction: _clearAllFilters,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${state.total} properties found',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.zinc500),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.listings.length) {
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
          ),
        ),
      ],
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'price_low':
        return 'Price ↑';
      case 'price_high':
        return 'Price ↓';
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      default:
        return 'Sort';
    }
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _sortOption('newest', '🆕 Newest First'),
              _sortOption('oldest', '📅 Oldest First'),
              _sortOption('price_low', '💰 Price: Low to High'),
              _sortOption('price_high', '💎 Price: High to Low'),
            ],
          ),
        );
      },
    );
  }

  Widget _sortOption(String value, String label) {
    final isSelected = _selectedSort == value;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.wave500 : AppColors.zinc400,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.wave600 : AppColors.zinc700,
        ),
      ),
      onTap: () {
        setState(() => _selectedSort = value);
        Navigator.pop(context);
        _performSearch();
      },
    );
  }

  bool _isFavorite(int listingId) {
    final favState = ref.read(favoritesProvider);
    return favState.favorites.any((f) => f.id == listingId);
  }

  bool _isToggling(int listingId) => false;

  Future<void> _toggleFavorite(int listingId) async {
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
  }
}
