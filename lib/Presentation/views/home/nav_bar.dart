import 'package:app/Presentation/themes/app_colors.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const HomeNavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // Use SafeArea with a minimal bottom inset and tighter padding
    // to avoid oversized nav bars and overlap with the iOS home indicator.
    return SafeArea(
      minimum: const EdgeInsets.only(left: 14, right: 14, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.20),
              width: 1,
            ),
            boxShadow: const [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
            child: GNav(
              selectedIndex: currentIndex,
              onTabChange: onTap,
              gap: 8,
              color: AppColors.textPrimary.withValues(alpha: 0.90),
              activeColor: AppColors.primaryColor,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              tabBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.apartment, text: 'Buildings'),
                GButton(icon: Icons.bar_chart, text: 'Reports'),
                GButton(icon: Icons.settings, text: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
