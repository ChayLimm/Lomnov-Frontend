import 'package:flutter/foundation.dart';

/// Domain model for App Notification
/// Represents a notification for the user
class AppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type;
  final String? status;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? payload;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.status,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.payload,
  });

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 24;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create a copy with updated values
  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? status,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    Map<String, dynamic>? payload,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      payload: payload ?? this.payload,
    );
  }

  /// Mark as read
  AppNotification markAsRead() {
    return copyWith(isRead: true);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          message == other.message &&
          createdAt == other.createdAt &&
          isRead == other.isRead &&
          type == other.type &&
          status == other.status &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phone == other.phone &&
          mapEquals(payload, other.payload);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      message.hashCode ^
      createdAt.hashCode ^
      isRead.hashCode ^
      type.hashCode ^
      (status?.hashCode ?? 0) ^
      (firstName?.hashCode ?? 0) ^
      (lastName?.hashCode ?? 0) ^
      (email?.hashCode ?? 0) ^
      (phone?.hashCode ?? 0) ^
      (payload == null ? 0 : payload.hashCode);

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, isRead: $isRead, createdAt: $createdAt, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, payload: $payload)';
  }
}
