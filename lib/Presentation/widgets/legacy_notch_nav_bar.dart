import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';

class LegacyNotchNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const LegacyNotchNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = NotchBottomBarController(index: currentIndex);
    return AnimatedNotchBottomBar(
      notchBottomBarController: controller,
      onTap: onTap,
      color: Theme.of(context).colorScheme.primary,
      notchColor: Theme.of(context).colorScheme.primary,
      showLabel: true,
      itemLabelStyle: const TextStyle(color: Colors.white),
      bottomBarHeight: 62,
      elevation: 8,
      removeMargins: false,
      bottomBarItems: const [
        BottomBarItem(
          inActiveItem: Icon(Icons.home_outlined, color: Colors.white70),
          activeItem: Icon(Icons.home, color: Colors.white),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.apartment_outlined, color: Colors.white70),
          activeItem: Icon(Icons.apartment, color: Colors.white),
          itemLabel: 'Buildings',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.bar_chart_outlined, color: Colors.white70),
          activeItem: Icon(Icons.bar_chart, color: Colors.white),
          itemLabel: 'Reports',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.settings_outlined, color: Colors.white70),
          activeItem: Icon(Icons.settings, color: Colors.white),
          itemLabel: 'Settings',
        ),
      ], kIconSize: 20, kBottomRadius: 20,
    );
  }
}
