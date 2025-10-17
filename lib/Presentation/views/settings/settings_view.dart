import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Account Settings',
            children: const [
              _Tile(icon: Icons.person_outline, label: 'Profile'),
              _Tile(icon: Icons.lock_outline, label: 'Password & Security'),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'System Settings',
            children: const [
              _Tile(icon: Icons.lightbulb_outline, label: 'Services'),
              _Tile(icon: Icons.account_balance_wallet_outlined, label: 'Account Bakong'),
              _Tile(icon: Icons.rule_folder_outlined, label: 'Rules'),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Others',
            children: const [
              _Tile(icon: Icons.support_agent_outlined, label: 'Contact Us'),
            ],
          ),
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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                // ignore: deprecated_member_use
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
