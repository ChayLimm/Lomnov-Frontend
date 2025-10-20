import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:app/Presentation/views/buildings/buildings_view.dart';
import 'package:app/Presentation/views/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(onViewBuildings: () => setState(() => _index = 1)),
      const BuildingsView(),
      const _ReportsTab(),
      const SettingsView(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: _index == 1
          ? null
          : AppBar(
              title: Text(_titleForIndex(_index)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => Get.offAllNamed('/'),
                  tooltip: 'Logout',
                ),
              ],
            ),
      body: pages[_index],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: CrystalNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              // Dark frosted glass background
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              // Subtle white outline like the screenshot
              outlineBorderColor: Colors.white.withValues(alpha: 0.40),
              borderWidth: 1,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              unselectedItemColor: Colors.white.withValues(alpha: 0.80),
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
        ),
      ),
    );
  }

  String _titleForIndex(int i) {
    switch (i) {
      case 0:
        return 'Home';
      case 1:
        return 'Buildings';
      case 2:
        return 'Reports';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }
}

// Buildings tab now shows the full BuildingsView directly (see pages list)
class _HomeTab extends StatelessWidget {
  final VoidCallback onViewBuildings;
  const _HomeTab({required this.onViewBuildings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('You are logged in!', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onViewBuildings,
            icon: const Icon(Icons.apartment),
            label: const Text('View Buildings'),
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Reports (coming soon)'));
  }
}
// end of file
