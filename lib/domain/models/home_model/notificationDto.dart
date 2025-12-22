import 'dart:convert';

import 'package:app/domain/models/home_model/meter_reading_payload.dart';
import 'package:app/domain/models/home_model/registration_payload.dart';

class Notification {
  final int? id;
  final int? paymentId;
  final String? notificationType;
  final String? email;
  final bool? read;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int? landlordId;
  final int? chatId;
  final String? status;
  final dynamic payload;

  Notification({
    this.id,
    this.paymentId,
    this.notificationType,
    this.email,
    this.read,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.landlordId,
    this.chatId,
    this.status,
    this.payload,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final type = json['notification_type']?.toString()?.toLowerCase();
    dynamic payloadData;
    
    if (json['payload'] != null) {
      payloadData = _parsePayload(json['payload'], type);
    }

    return Notification(
      id: _parseInt(json['id']),
      paymentId: _parseInt(json['payment_id']),
      notificationType: type,
      email: json['email']?.toString(),
      read: json['read'] as bool?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      deletedAt: _parseDateTime(json['deleted_at']),
      landlordId: _parseInt(json['landlord_id']),
      chatId: _parseInt(json['chat_id']),
      status: json['status']?.toString(),
      payload: payloadData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'payment_id': paymentId,
      'notification_type': notificationType,
      'email': email,
      'read': read,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'landlord_id': landlordId,
      'chat_id': chatId,
      'status': status,
    };

    // Handle payload based on type
    if (payload != null) {
      if (payload is MeterReadingPayload) {
        data['payload'] = (payload as MeterReadingPayload).toJson();
      } else if (payload is RegistrationPayload) {
        data['payload'] = (payload as RegistrationPayload).toJson();
      } else if (payload is Map<String, dynamic>) {
        data['payload'] = payload;
      } else if (payload is String) {
        data['payload'] = payload;
      }
    }

    return data;
  }

  static dynamic _parsePayload(dynamic payloadData, String? type) {
    if (payloadData == null) return null;

    // Parse based on notification type
    switch (type) {
      case 'meter_reading':
      case 'payment': // Assuming payment uses meter reading payload
        return MeterReadingPayload.fromDynamic(payloadData);
      case 'registration':
        return RegistrationPayload.fromDynamic(payloadData);
      default:
        // Return as raw JSON if type not recognized
        return payloadData;
    }
  }

  Notification copyWith({
    int? id,
    int? paymentId,
    String? notificationType,
    String? email,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? landlordId,
    int? chatId,
    String? status,
    dynamic payload,
  }) {
    return Notification(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      notificationType: notificationType ?? this.notificationType,
      email: email ?? this.email,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      landlordId: landlordId ?? this.landlordId,
      chatId: chatId ?? this.chatId,
      status: status ?? this.status,
      payload: payload ?? this.payload,
    );
  }

  // Getters for type-safe payload access
  MeterReadingPayload? get meterReadingPayload {
    if (payload is MeterReadingPayload) {
      return payload as MeterReadingPayload;
    }
    return null;
  }

  RegistrationPayload? get registrationPayload {
    if (payload is RegistrationPayload) {
      return payload as RegistrationPayload;
    }
    return null;
  }

  @override
  String toString() {
    return 'Notification(id: $id, type: $notificationType, read: $read)';
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}