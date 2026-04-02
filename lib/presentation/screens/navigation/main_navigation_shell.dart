import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';

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
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.zinc300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.add_circle_outline,
              size: 64,
              color: AppColors.navy400,
            ),
            const SizedBox(height: 24),
            Text(
              'Create Listing',
              style: AppTextStyles.headline4,
            ),
            const SizedBox(height: 8),
            Text(
              'This feature will be available soon. You will be able to list your properties for sale or rent.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
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
                child: const Text('Got It'),
              ),
            ),
          ],
        ),
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
