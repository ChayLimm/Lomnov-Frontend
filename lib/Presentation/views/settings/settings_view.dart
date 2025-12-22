import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/views/settings/services/service_view.dart';
import 'package:app/Presentation/views/settings/room_type/room_type_view.dart';
import 'package:app/Presentation/views/settings/contact/contact_us_view.dart';
import 'package:app/Presentation/views/settings/meter_prices_view.dart';
import 'package:app/Presentation/views/settings/rules_regulations_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Setting',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Account Settings',
            children: [
              _Tile(icon: Icons.person_outline, label: 'Profile', onTap: () => Get.toNamed('/edit-profile')),
              // const _Tile(icon: Icons.lock_outline, label: 'Password & Security'),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'System Settings',
            children: [
              _Tile(icon: Icons.lightbulb_outline, label: 'Services', onTap: () => Get.to(() => const ServiceView())),
              const _Tile(icon: Icons.account_balance_wallet_outlined, label: 'Account Bakong'),
              _Tile(icon: Icons.gas_meter_outlined, label: 'Meter Prices', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MeterPricesView()))),
              _Tile(icon: Icons.rule_rounded, label: 'Rules & Regulations', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RulesRegulationsView()))),
              _Tile(icon: Icons.room_service_outlined, label: 'Room Types', onTap: () => Get.to(() => const RoomTypeView())),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Others',
            children: [
              _Tile(icon: Icons.support_agent_outlined, label: 'Contact Us', onTap: () => Get.to(() => const ContactUsView())),
            ],
          ),
          const SizedBox(height: 20),
          _LogoutButton(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.dividerColor.withValues(alpha: 0.7)),
          ...children,
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _Tile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Log out'),
        onPressed: () {
          // Call auth logout if available then navigate to login
          final auth = context.read<AuthViewModel>();
          auth.logout();
          Get.offAllNamed('/');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
