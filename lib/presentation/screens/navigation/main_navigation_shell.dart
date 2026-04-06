import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/app_providers.dart';
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

    // Watch unread messages count
    final unreadMessagesAsync = ref.watch(unreadMessagesCountProvider);
    final unreadCount = unreadMessagesAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: AppColors.zinc50,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        ),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.navy900, size: 30),
            const SizedBox(height: 2),
            Text(
              "List",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.navy900,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, "Home", 0),
              _buildNavItem(Icons.favorite_rounded, "Saved", 1),
              const SizedBox(width: 48), // Space for FAB notch
              _buildMessagesNavItem(unreadCount),
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

  Widget _buildMessagesNavItem(int unreadCount) {
    final isSelected = _selectedIndex == 3;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unreadCount > 0)
              Badge(
                label: Text(
                  '$unreadCount',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.wave500,
                textColor: Colors.white,
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: isSelected ? AppColors.navy900 : AppColors.zinc400,
                  size: 26,
                ),
              )
            else
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: isSelected ? AppColors.navy900 : AppColors.zinc400,
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              "Messages",
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
