import 'package:app/presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app/presentation/views/buildings/buildings_view.dart';
import 'package:app/presentation/views/settings/settings_view.dart';
import 'package:app/presentation/views/reports/report_view.dart';
import 'package:app/presentation/views/home/home_parts/home_tab.dart';
import 'package:app/presentation/views/home/nav_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _index = 0;
  DateTime? _lastNavTap;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTab(onViewBuildings: () => setState(() => _index = 1)),
      const BuildingsView(),
      const ReportView(),
      const SettingsView(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBody: true,
      // Hide the default AppBar on tabs that provide their own headers (Home, Buildings, Reports, Settings)
      appBar: (_index == 0 || _index == 1 || _index == 2 || _index == 3)
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
      bottomNavigationBar: HomeNavBar(currentIndex: _index, onTap: _onNavTap),
    );
  }

  void _onNavTap(int i) {
    final now = DateTime.now();
    // Throttle rapid taps to avoid firing many page rebuilds/requests.
    if (_lastNavTap != null && now.difference(_lastNavTap!) < const Duration(milliseconds: 300)) return;
    _lastNavTap = now;
    setState(() => _index = i);
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

// Reports tab is now provided by ReportView in reports/report_view.dart



