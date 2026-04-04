import 'package:flutter/material.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../listing/create_listing_screen.dart';

/// Main Navigation Shell with Bottom Navigation Bar
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreateListingPlaceholder(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: WaveBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Create Listing - Show placeholder for now
            _showCreateListingInfo();
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }

  void _showCreateListingInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateListingScreen(),
      ),
    );
  }
}

/// Placeholder for Create Listing Screen
class CreateListingPlaceholder extends StatelessWidget {
  const CreateListingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const WaveEmptyState(
      icon: Icons.add_circle_outline,
      title: 'Create Listing',
      subtitle: 'This feature is coming soon',
    );
  }
}
