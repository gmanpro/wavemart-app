import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Search Screen with filters
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _buildActiveFilters(),

          // Results
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Results Count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '24 Properties Found',
                          style: AppTextStyles.bodyMedium,
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {},
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
                                'Sort',
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

                // Listings Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const PropertyListingCard(),
                      childCount: 10,
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
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
            onPressed: () {},
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
            _buildFilterChip('Addis Ababa', Icons.location_on),
            const SizedBox(width: 8),
            _buildFilterChip('House', Icons.home),
            const SizedBox(width: 8),
            _buildFilterChip('5M - 10M ETB', Icons.attach_money),
            const SizedBox(width: 8),
            _buildFilterChip('3+ Beds', Icons.bed),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
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
            onTap: () {},
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
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
                    onPressed: () {},
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
                      _buildRadioTile('All Types', 'all'),
                      _buildRadioTile('House', 'house'),
                      _buildRadioTile('Land', 'land'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Listing Type',
                    children: [
                      _buildRadioTile('Sale', 'sale'),
                      _buildRadioTile('Rent', 'rental'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Price Range',
                    children: [
                      _buildRadioTile('Under 5M ETB', '0-5000000'),
                      _buildRadioTile('5M - 10M ETB', '5000000-10000000'),
                      _buildRadioTile('10M - 50M ETB', '10000000-50000000'),
                      _buildRadioTile('50M+ ETB', '50000000-999999999'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Bedrooms',
                    children: [
                      _buildRadioTile('Any', '0'),
                      _buildRadioTile('1+', '1'),
                      _buildRadioTile('2+', '2'),
                      _buildRadioTile('3+', '3'),
                      _buildRadioTile('4+', '4'),
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
                  onPressed: () => Navigator.pop(context),
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

  Widget _buildRadioTile(String label, String value) {
    return RadioListTile<String>(
      value: value,
      groupValue: 'all',
      onChanged: (value) {},
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.wave500,
    );
  }
}
