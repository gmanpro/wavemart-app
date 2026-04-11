import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
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
  int? _selectedPriceMin;
  int? _selectedPriceMax;
  String? _selectedPriceLabel;
  Map<String, dynamic> _activeFilters = {};
  bool _hasSearched = false;
  bool _rentalEnabled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final response = await ApiClient().dio.get(ApiConstants.apiBase + '/settings');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          setState(() {
            _rentalEnabled = data['rental_enabled'] == true;
          });
        }
      }
    } catch (_) {
      // Silently fail - default to rental disabled
    }
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
    if (_selectedListingType != null) _activeFilters['listing_type'] = _selectedListingType;
    _activeFilters['sort'] = _selectedSort;

    // Price range filter
    if (_selectedPriceMin != null) _activeFilters['price_min'] = _selectedPriceMin!;
    if (_selectedPriceMax != null) _activeFilters['price_max'] = _selectedPriceMax!;

    setState(() => _hasSearched = true);
    ref.read(listingsProvider.notifier).loadListings(filters: _activeFilters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedListingType = null;
      _selectedSort = 'newest';
      _selectedPriceMin = null;
      _selectedPriceMax = null;
      _selectedPriceLabel = null;
      _activeFilters = {};
      _hasSearched = false;
      _searchController.clear();
    });
  }

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedListingType != null ||
      _selectedSort != 'newest' ||
      _selectedPriceLabel != null ||
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
          // Type dropdown
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
          // Sort button
          const SizedBox(width: 8),
          _sortButton(),
          // Filter button
          const SizedBox(width: 8),
          _filterButton(),
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
      onTap: () => _showFilterModal(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.zinc50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.zinc200),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 18, color: AppColors.zinc600),
            SizedBox(width: 4),
            Text(
              'Filters',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navy800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton() {
    return GestureDetector(
      onTap: () => _showFilterModal(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.zinc50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.zinc200),
        ),
        child: const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.zinc600),
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
                () {
                  setState(() => _selectedType = null);
                  _performSearch();
                },
              ),
            if (_selectedListingType != null)
              _filterChip(
                _selectedListingType == 'sale' ? '💰 For Sale' : '🔑 For Rent',
                () {
                  setState(() => _selectedListingType = null);
                  _performSearch();
                },
              ),
            if (_selectedPriceLabel != null)
              _filterChip(
                '💵 $_selectedPriceLabel',
                () {
                  setState(() {
                    _selectedPriceLabel = null;
                    _selectedPriceMin = null;
                    _selectedPriceMax = null;
                  });
                  _performSearch();
                },
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
              _popularSearchChip('🏠 Houses', () {
                setState(() => _selectedType = 'house');
                _performSearch();
              }),
              _popularSearchChip('🌄 Lands', () {
                setState(() => _selectedType = 'land');
                _performSearch();
              }),
              _popularSearchChip('💰 For Sale', () {
                setState(() => _selectedListingType = 'sale');
                _performSearch();
              }),
              if (_rentalEnabled)
                _popularSearchChip('🔑 For Rent', () {
                  setState(() => _selectedListingType = 'rental');
                  _performSearch();
                }),
              _popularSearchChip('💰 Under 5M', () {
                setState(() {
                  _selectedPriceLabel = 'Under 5M';
                  _selectedPriceMin = 0;
                  _selectedPriceMax = 5000000;
                });
                _performSearch();
              }),
              _popularSearchChip('💎 5M - 10M', () {
                setState(() {
                  _selectedPriceLabel = '5M - 10M';
                  _selectedPriceMin = 5000000;
                  _selectedPriceMax = 10000000;
                });
                _performSearch();
              }),
              _popularSearchChip('🏆 10M - 50M', () {
                setState(() {
                  _selectedPriceLabel = '10M - 50M';
                  _selectedPriceMin = 10000000;
                  _selectedPriceMax = 50000000;
                });
                _performSearch();
              }),
              _popularSearchChip('👑 50M - 100M', () {
                setState(() {
                  _selectedPriceLabel = '50M - 100M';
                  _selectedPriceMin = 50000000;
                  _selectedPriceMax = 100000000;
                });
                _performSearch();
              }),
              _popularSearchChip('✨ 100M+', () {
                setState(() {
                  _selectedPriceLabel = '100M+';
                  _selectedPriceMin = 100000000;
                  _selectedPriceMax = null;
                });
                _performSearch();
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
      return _buildSkeletonList(5);
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
          child: Stack(
            children: [
              ListView.builder(
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
              if (state.isLoading && state.listings.isNotEmpty)
                Positioned.fill(
                  child: Container(
                    color: AppColors.zinc50.withOpacity(0.7),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList(int count) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.zinc200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: AppColors.zinc200),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, width: 120, color: AppColors.zinc200),
                      const SizedBox(height: 10),
                      Container(height: 16, width: double.infinity, color: AppColors.zinc200),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 180, color: AppColors.zinc200),
                      const SizedBox(height: 14),
                      Row(children: [
                        Container(height: 20, width: 60, color: AppColors.zinc200),
                        const SizedBox(width: 8),
                        Container(height: 20, width: 45, color: AppColors.zinc200),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedType = null;
                              _selectedListingType = null;
                              _selectedSort = 'newest';
                              _selectedPriceLabel = null;
                              _selectedPriceMin = null;
                              _selectedPriceMax = null;
                            });
                          },
                          child: const Text('Reset', style: TextStyle(color: AppColors.zinc500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Property Type
                    const Text('Property Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _modalChipRow([
                      ('All', null, _selectedType == null),
                      ('🏠 House', 'house', _selectedType == 'house'),
                      ('🌄 Land', 'land', _selectedType == 'land'),
                    ], (v) {
                      setModalState(() => _selectedType = v);
                    }),

                    const SizedBox(height: 16),

                    // Listing Status (only if rental enabled)
                    if (_rentalEnabled) ...[
                      const Text('Listing Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _modalChipRow([
                        ('All', null, _selectedListingType == null),
                        ('💰 For Sale', 'sale', _selectedListingType == 'sale'),
                        ('🔑 For Rent', 'rental', _selectedListingType == 'rental'),
                      ], (v) {
                        setModalState(() => _selectedListingType = v);
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Price Range
                    const Text('Price Range', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _modalChipRow([
                      ('Any', null, _selectedPriceLabel == null),
                      ('💰 Under 5M', 'Under 5M', _selectedPriceLabel == 'Under 5M'),
                      ('💎 5M-10M', '5M-10M', _selectedPriceLabel == '5M-10M'),
                      ('🏆 10M-50M', '10M-50M', _selectedPriceLabel == '10M-50M'),
                      ('👑 50M-100M', '50M-100M', _selectedPriceLabel == '50M-100M'),
                      ('✨ 100M+', '100M+', _selectedPriceLabel == '100M+'),
                    ], (v) {
                      setModalState(() => _setPriceFilter(v as String?));
                    }),

                    const SizedBox(height: 16),

                    // Sort By (last)
                    const Text('Sort By', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _modalChipRow([
                      ('🆕 Newest', 'newest', _selectedSort == 'newest'),
                      ('📅 Oldest', 'oldest', _selectedSort == 'oldest'),
                      ('💰 Price ↑', 'price_low', _selectedSort == 'price_low'),
                      ('💎 Price ↓', 'price_high', _selectedSort == 'price_high'),
                    ], (v) {
                      setModalState(() => _selectedSort = v as String);
                    }),

                    const SizedBox(height: 24),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _performSearch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.wave500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _setPriceFilter(String? label) {
    _selectedPriceLabel = label;
    switch (label) {
      case 'Under 5M':
        _selectedPriceMin = 0;
        _selectedPriceMax = 5000000;
        break;
      case '5M-10M':
        _selectedPriceMin = 5000000;
        _selectedPriceMax = 10000000;
        break;
      case '10M-50M':
        _selectedPriceMin = 10000000;
        _selectedPriceMax = 50000000;
        break;
      case '50M-100M':
        _selectedPriceMin = 50000000;
        _selectedPriceMax = 100000000;
        break;
      case '100M+':
        _selectedPriceMin = 100000000;
        _selectedPriceMax = null;
        break;
      default:
        _selectedPriceMin = null;
        _selectedPriceMax = null;
    }
  }

  Widget _modalChipRow(List<(String, dynamic, bool)> chips, void Function(dynamic) onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((chip) {
        final (label, value, isSelected) = chip;
        return GestureDetector(
          onTap: () => onSelected(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.wave500 : AppColors.zinc100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.zinc700,
              ),
            ),
          ),
        );
      }).toList(),
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
