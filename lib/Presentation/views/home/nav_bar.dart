import 'package:app/presentation/themes/app_colors.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
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
        child: CrystalNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          outlineBorderColor: AppColors.primaryColor.withValues(alpha: 0.25),
          borderWidth: 1,
          boxShadow: const [],
          unselectedItemColor: AppColors.textPrimary.withValues(alpha: 0.90),
          selectedItemColor: AppColors.primaryColor,
          borderRadius: 28,
          height: 64,
          enableFloatingNavBar: true,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          items: [
            CrystalNavigationBarItem(
              icon: Icons.home,
              unselectedIcon: Icons.home_outlined,
            ),
            CrystalNavigationBarItem(
              icon: Icons.apartment,
              unselectedIcon: Icons.apartment_outlined,
            ),
            CrystalNavigationBarItem(
              icon: Icons.bar_chart,
              unselectedIcon: Icons.bar_chart_outlined,
            ),
            CrystalNavigationBarItem(
              icon: Icons.settings,
              unselectedIcon: Icons.settings_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
