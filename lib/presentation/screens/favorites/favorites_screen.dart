import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Favorites Screen - Wired to favoritesProvider
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
        actions: [
          if (state.favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${state.favorites.length}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.wave600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(FavoritesState state) {
    // Loading state
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (state.errorMessage != null) {
      return WaveErrorBanner(
        message: state.errorMessage!,
        onRetry: () {
          ref.read(favoritesProvider.notifier).loadFavorites();
        },
      );
    }

    // Empty state
    if (state.favorites.isEmpty) {
      return WaveEmptyState(
        icon: Icons.favorite_border,
        title: 'No Saved Properties',
        subtitle: 'Start saving properties you like to see them here',
        actionLabel: 'Browse Properties',
        onAction: () {
          // Navigate to home tab (index 0)
          Navigator.of(context).pop();
        },
      );
    }

    // Favorites list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final listing = state.favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Dismissible(
            key: Key('favorite_${listing.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red[500],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Favorite'),
                  content: const Text('Remove this property from saved list?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              final success = await ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(listing.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Property removed from favorites'),
                    backgroundColor: AppColors.wave500,
                  ),
                );
              }
            },
            child: PropertyListingCard(listing: listing),
          ),
        );
      },
    );
  }
}
