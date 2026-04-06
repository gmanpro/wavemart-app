import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';
import '../listing/create_listing_screen.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) return; // FAB button
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      const Center(child: Text('')), // Placeholder for FAB
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        ),
        backgroundColor: AppColors.navy900,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "Home", 0),
              _buildNavItem(Icons.favorite_rounded, "Saved", 1),
              const SizedBox(width: 36), // Space for FAB
              _buildNavItem(Icons.chat_bubble_outline_rounded, "Messages", 3),
              _buildNavItem(Icons.person_outline_rounded, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.navy900 : AppColors.zinc400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.navy900 : AppColors.zinc500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
