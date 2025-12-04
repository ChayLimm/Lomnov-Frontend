import 'package:app/Presentation/themes/app_colors.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const HomeNavBar({required this.currentIndex, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.25), width: 1),
            boxShadow: const [],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: GNav(
                selectedIndex: currentIndex,
                onTabChange: onTap,
                gap: 8,
                color: AppColors.textPrimary.withValues(alpha: 0.90),
                activeColor: AppColors.primaryColor,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                tabBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
                tabs: [
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.apartment, text: 'Buildings'),
                  GButton(icon: Icons.bar_chart, text: 'Reports'),
                  GButton(icon: Icons.settings, text: 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
