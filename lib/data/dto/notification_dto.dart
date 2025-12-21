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
  final String? status;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;

  const NotificationDto({
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
  });

  /// Create from API JSON response
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    // Support different backend shapes, including landlord-scoped notifications
    final data = json['data'] ?? json;

    // Common helpers
    String parseTitle(Map<String, dynamic> d) {
      final nt = d['notification_type'] ?? d['type'] ?? d['notificationType'];
      if (nt is String && nt.isNotEmpty) return nt[0].toUpperCase() + nt.substring(1);
      final status = d['status'];
      if (status is String) return status[0].toUpperCase() + status.substring(1);
      return 'Notification';
    }

    String parseMessage(Map<String, dynamic> d) {
      // Prefer explicit message
      if (d['message'] is String && (d['message'] as String).isNotEmpty) return d['message'] as String;

      // If payload is present, try to summarize
      final payload = d['payload'];
      if (payload is Map<String, dynamic>) {
        final fn = payload['first_name'] ?? payload['firstName'];
        final ln = payload['last_name'] ?? payload['lastName'];
        final phone = payload['phone'];
        if (fn != null || ln != null) {
          final name = '${fn ?? ''}${fn != null && ln != null ? ' ' : ''}${ln ?? ''}'.trim();
          return 'Registration request from $name${phone != null ? ' ($phone)' : ''}';
        }
        if (payload['email'] is String) return 'Registration details for ${payload['email']}';
      }

      // Fallback to email/status fields
      if (d['email'] is String) return 'Email: ${d['email']}';
      if (d['status'] is String) return 'Status: ${d['status']}';

      return '';
    }

    final idVal = data['id'] ?? 0;
    final createdAtRaw = data['created_at'] ?? data['createdAt'] ?? data['updated_at'];
    DateTime createdAt;
    try {
      createdAt = createdAtRaw != null ? DateTime.parse(createdAtRaw.toString()) : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    final isReadVal = data['is_read'] ?? data['isRead'] ?? data['read'] ?? false;

    // extract payload fields if present
    String? fn;
    String? ln;
    String? em;
    String? ph;
    String? st;
    if (data is Map<String, dynamic>) {
      final payload = data['payload'];
      if (payload is Map<String, dynamic>) {
        fn = (payload['first_name'] ?? payload['firstName'])?.toString();
        ln = (payload['last_name'] ?? payload['lastName'])?.toString();
        em = (payload['email'] ?? payload['emailAddress'])?.toString();
        ph = (payload['phone'])?.toString();
        st = (payload['status'] ?? payload['registration_status'])?.toString();
      } else {
        fn = (data['first_name'] ?? data['firstName'])?.toString();
        ln = (data['last_name'] ?? data['lastName'])?.toString();
        em = (data['email'])?.toString();
        ph = (data['phone'])?.toString();
        st = (data['status'])?.toString();
      }
    }

    return NotificationDto(
      id: idVal is int ? idVal : (int.tryParse(idVal?.toString() ?? '') ?? 0),
      title: parseTitle(data as Map<String, dynamic>),
      message: parseMessage(data as Map<String, dynamic>),
      createdAt: createdAt,
      isRead: isReadVal == true || isReadVal == 1,
      type: (data['notification_type'] ?? data['type'])?.toString(),
      status: st,
      firstName: fn,
      lastName: ln,
      email: em,
      phone: ph,
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
      status: status,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
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
      firstName: domain.firstName,
      lastName: domain.lastName,
      email: domain.email,
      phone: domain.phone,
    );
  }
}
