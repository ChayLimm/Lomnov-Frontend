import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Presentation/provider/notifications/notification_provider.dart';
import 'package:app/Presentation/widgets/empty1.dart';
import 'package:app/Presentation/widgets/error1.dart';
import 'package:app/Presentation/views/notifications/widgets/landlord_notification_card.dart';
import 'package:app/Presentation/views/notifications/registration_detail.dart';
import 'package:app/Presentation/views/payment/payment_view.dart';
import 'package:app/Presentation/views/notifications/payment_detail.dart';
import 'package:get/get.dart';
import 'package:app/Presentation/themes/text_styles.dart';
import 'package:app/Presentation/themes/app_colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationState()..load(),
      child: const _NotificationsScreen(),
    );
  }
}

class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        title: Text(
          'Notifications',
          style: LomTextStyles.headline1(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: const [SizedBox(width: kToolbarHeight)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _Tabs(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Recents',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: (state.isLoading || state.error != null ||
                          !state.filtered.any((n) => !n.isRead))
                      ? null
                      : state.markAllAsRead,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                  ),
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _Body()),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xC9C9C9C9),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(0),
        height: 60,
        child: Stack(
          children: [
            // Sliding highlight
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: state.tab == NotificationTab.payment
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
                child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,

                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Labels and taps
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context
                        .read<NotificationState>()
                        .switchTab(NotificationTab.payment),
                    child: Center(
                      child: Text(
                        'Payment',
                        style: LomTextStyles.headline2(
                          size: 16,
                          fontWeight: FontWeight.w600,
                          color: state.tab == NotificationTab.payment
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context
                        .read<NotificationState>()
                        .switchTab(NotificationTab.registration),
                    child: Center(
                      child: Text(
                        'Registration',
                        style: LomTextStyles.headline2(
                          size: 16,
                          fontWeight: FontWeight.w600,
                          color: state.tab == NotificationTab.registration
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return ErrorState(message: state.error);
    }

    final items = state.filtered;
    if (items.isEmpty) {
      return const EmptyState(
        title: 'No Notification for now',
        subtitle: 'There will be notification soon',
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
            return LandlordNotificationCard(
        item: item,
        onTap: () {
          final t = (item.type ?? '').toLowerCase();
            if (t == 'registration') {
            Get.to(() => RegistrationDetail(notification: item));
          } else if (t == 'payment') {
            // Open payment detail with payload (editable) and mark notification as read
            final result = Get.to(() => PaymentDetail(
                  payload: item.payload ?? {},
                  notificationId: item.id,
                ));
            context.read<NotificationState>().markAsRead(item.id);
            // Optional: handle returned result if needed
            // result?.then((res) => print('Payment detail result: $res'));
          } else {
            // Default behaviour: mark as read
            context.read<NotificationState>().markAsRead(item.id);
          }
        },
      );
      },
    );
  }
}
