import 'package:flutter/material.dart';
import 'package:app/domain/models/home_model/notification_model.dart';

class NotificationListItem extends StatelessWidget {
  final AppNotification item;
  final VoidCallback? onTap;

  const NotificationListItem({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Icon(
          _iconForType(item.type),
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        item.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        item.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        item.timeAgo,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
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
