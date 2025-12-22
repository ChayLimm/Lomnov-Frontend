import 'package:flutter/material.dart';
import 'package:app/domain/models/home_model/notification_model.dart';

class LandlordNotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback? onTap;

  const LandlordNotificationCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: (){
        print("object");
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
        child: Icon(_iconForType(item.type), color: theme.colorScheme.primary),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            item.message.isNotEmpty ? item.message : (item.type ?? ''),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_filled, size: 12, color: theme.hintColor),
              const SizedBox(width: 6),
              Text(item.timeAgo, style: theme.textTheme.bodySmall),
            ],
          )
        ],
      ),
      trailing: item.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
    );
  }

  IconData _iconForType(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'payment':
        return Icons.payment_rounded;
      case 'registration':
        return Icons.app_registration_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
