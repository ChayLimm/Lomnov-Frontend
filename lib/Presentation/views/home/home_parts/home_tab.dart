import 'package:app/Presentation/provider/auth_viewmodel.dart';
import 'package:app/Presentation/views/home/home_parts/status_card.dart';
import 'package:app/Presentation/views/home/home_parts/quick_actions_grid.dart';
import 'package:app/Presentation/views/home/home_parts/receipts_section.dart';
import 'package:app/Presentation/views/home/home_parts/overview_card.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_status.dart';
import 'package:app/data/mock_data/mock_data.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback onViewBuildings;
  const HomeTab({required this.onViewBuildings, super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.user;
    return SafeArea(
      child: FutureBuilder<DashboardSummary>(
        future: fetchDashboardMock(),
        builder: (context, snap) {
          final data = snap.data;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provide screenshot-like defaults when mock data isn't ready
                      _Header(
                        userName: user?.name ?? data?.userName ?? 'Mock',
                        avatarUrl: user?.avatarUrl ?? data?.avatarUrl,
                      ),
                      const SizedBox(height: 12),
                      const Text('Overview',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _RoundedSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OverviewCard(summary: data),
                            const SizedBox(height: 6),
                            Divider(
                              height: 0,
                              thickness: 1,
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 6),
                            _StatusesGrid(summary: data),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const QuickActionsGrid(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Receipts section without outer horizontal padding
                const ReceiptsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  const _Header({required this.userName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          child: avatarUrl == null
              ? const Icon(Icons.person, color: AppColors.primaryColor)
              : ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.person, color: AppColors.primaryColor),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed('/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
        )
      ],
    );
  }
}



class _StatusesGrid extends StatelessWidget {
  final DashboardSummary? summary;
  const _StatusesGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final counts = summary?.counts ??
        const {
          InvoiceStatus.unpaid: 4,
          InvoiceStatus.pending: 4,
          InvoiceStatus.paid: 30,
          InvoiceStatus.delay: 1,
        };
    final regularItems = <StatusItem>[
      StatusItem(label: 'Unpaid', count: counts[InvoiceStatus.unpaid] ?? 0, color: Colors.grey.shade600),
      StatusItem(label: 'Pending', count: counts[InvoiceStatus.pending] ?? 0, color: AppColors.warningColor),
      StatusItem(label: 'Paid', count: counts[InvoiceStatus.paid] ?? 0, color: AppColors.successColor),
    ];

    // the delay item with a button
    final delayItem = StatusItem(
      label: 'Delay',
      count: counts[InvoiceStatus.delay] ?? 0,
      color: AppColors.errorColor,
      countStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
      spacing: 20,
      trailing: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Send reminders'),
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      const crossAxisCount = 3;
      const crossAxisSpacing = 8.0;
      const childAspectRatio = 2.0;
      final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
      final itemHeight = itemWidth / childAspectRatio;

      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: regularItems.length,
            itemBuilder: (_, i) => StatusCard(item: regularItems[i]),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: itemHeight,
            child: StatusCard(item: delayItem),
          ),
        ],
      );
    });
  }
}

/// A rounded, surface-colored container to visually group sections
class _RoundedSection extends StatelessWidget {
  final Widget child;
  const _RoundedSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color (0xFFEDEEF3),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}


