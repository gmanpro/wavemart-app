import 'package:flutter/material.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Favorites Screen - Saved listings
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
      ),
      body: const WaveEmptyState(
        icon: Icons.favorite_border,
        title: 'No Saved Properties',
        subtitle: 'Start saving properties you like to see them here',
        actionLabel: 'Browse Properties',
      ),
    );
  }
}
