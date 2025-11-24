import 'package:app/domain/models/home_model/notification_model.dart';

/// Data Transfer Object for AppNotification
/// Handles JSON serialization/deserialization for API communication
class NotificationDto {
  final int id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
  });

  /// Create from API JSON response
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return NotificationDto(
      id: data['id'] ?? 0,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'].toString())
          : DateTime.now(),
      isRead: data['is_read'] ?? data['isRead'] ?? false,
      type: data['type'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead,
    'type': type,
  };

  /// Convert DTO to domain model
  AppNotification toDomain() {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead,
      type: type,
    );
  }

  /// Create DTO from domain model
  factory NotificationDto.fromDomain(AppNotification domain) {
    return NotificationDto(
      id: domain.id,
      title: domain.title,
      message: domain.message,
      createdAt: domain.createdAt,
      isRead: domain.isRead,
      type: domain.type,
    );
  }
}
