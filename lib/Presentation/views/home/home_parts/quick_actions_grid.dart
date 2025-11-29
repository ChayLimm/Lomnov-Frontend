import 'package:app/presentation/views/home/home_parts/quick_action_card.dart';
import 'package:app/presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Action',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionCard(
              gradient: AppColors.primaryGradient,
              title: 'Pay Now',
              value: '920',
              icon: Icons.receipt_long,
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              gradient: AppColors.primaryGradient,
              title: 'Add tenant',
              value: '52',
              icon: Icons.person_add_alt_1,
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              gradient: AppColors.primaryGradient,
              title: 'Create Room',
              value: '',
              icon: Icons.meeting_room,
            ),
          ],
        ),
      ],
    );
  }
}
