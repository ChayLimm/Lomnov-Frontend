import 'package:app/Presentation/views/home/home_parts/quick_action_card.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/Presentation/views/payment/payment_view.dart';
import 'package:app/Presentation/views/settings/services/service_view.dart';
import 'package:app/Presentation/views/settings/room_type/room_type_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  void onTapProcessPayment(){
    Get.to(() => PaymentView());
  }

  void onTapServices(){
    Get.to(() => const ServiceView());
  }

  void onTapRoomTypes(){
    Get.to(() => const RoomTypeView());
  }

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
              title: 'Payment',
              value: 'make',
              icon: Icons.receipt_long,
              onTap:onTapProcessPayment
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              gradient: AppColors.primaryGradient,
              title: 'Services',
              value: 'Add',
              icon: Icons.person_add_alt_1,
              onTap: onTapServices,
            ),
            const SizedBox(width: 12),
            QuickActionCard(
              gradient: AppColors.primaryGradient,
              title: 'Room-Type',
              value: 'Add',
              icon: Icons.meeting_room,
              onTap: onTapRoomTypes,
            ),
          ],
        ),
      ],
    );
  }
}
