import 'dart:convert';
import 'dart:developer' as dev; 
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/domain/models/home_model/meter_reading_payload.dart';
import 'package:app/domain/models/home_model/notificationDto.dart';
import 'package:app/domain/models/home_model/registration_payload.dart';

class NotificationService extends ApiBase {
  // GET /api/notifications
  Future<List<Notification>> fetchAll() async {
    final uri = buildUri(Endpoints.notifications);
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load notifications',
    );

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['notifications'] is List) {
        list = decoded['notifications'] as List;
      }
    }
    list ??= const [];

    // Changed from NotificationDto.fromJson to Notification.fromJson
    return list.map((e) => Notification.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/notifications/unread
  Future<List<Notification>> fetchUnread() async {
    final uri = buildUri(Endpoints.notificationsUnread);
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load unread notifications',
    );

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['notifications'] is List) {
        list = decoded['notifications'] as List;
      }
    }
    list ??= const [];

    // Changed from NotificationDto.fromJson to Notification.fromJson
    return list.map((e) => Notification.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /api/notifications/landlord/{id}
  Future<List<Notification>> fetchByLandlord(int landlordId) async {
    final uri = buildUri(Endpoints.notificationsByLandlord(landlordId));
    final headers = await buildHeaders();

    dev.log('[HTTP] GET $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleListResponse(
      response,
      'Failed to load landlord notifications',
    );

    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is List) {
        list = decoded['data'] as List;
      } else if (decoded['notifications'] is List) {
        list = decoded['notifications'] as List;
      }
    }
    list ??= const [];

    // Changed from NotificationDto.fromJson to Notification.fromJson
    return list.map((e) => Notification.fromJson(e as Map<String, dynamic>)).toList();
  }

  // PATCH /api/notifications/{id}/read
  Future<Notification> markAsRead(int id) async {
    final uri = buildUri(Endpoints.notificationMarkRead(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] PATCH $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.patch(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to mark notification as read',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        // Changed from NotificationDto.fromJson to Notification.fromJson
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      // Changed from NotificationDto.fromJson to Notification.fromJson
      return Notification.fromJson(decoded);
    }

    throw Exception('Unexpected response format');
  }

  // POST /api/notifications
  Future<Notification> create({
    required String title,
    required String message,
    String? type,
  }) async {
    final uri = buildUri(Endpoints.notifications);
    final headers = await buildHeaders();

    final payload = <String, dynamic>{
      'title': title,
      'message': message,
      if (type != null) 'type': type,
    };

    dev.log('[HTTP] POST $uri body=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to create notification',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        // Changed from NotificationDto.fromJson to Notification.fromJson
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      // Changed from NotificationDto.fromJson to Notification.fromJson
      return Notification.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  // PATCH /api/notifications/{id}/approve-registration
  Future<Notification> approveRegistration({
    required int notificationId,
    required int roomId,
    required num deposit,
    required String startDate,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final uri = buildUri(Endpoints.notificationApproveRegistration(notificationId));
    final headers = await buildHeaders();

    final payload = <String, dynamic>{
      'room_id': roomId,
      'deposit': deposit,
      'start_date': startDate,
    };
    void addIf(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      payload[key] = value;
    }

    // Add multiple key variants to increase compatibility with backend expectations
    if (firstName != null && firstName.trim().isNotEmpty) {
      addIf('first_name', firstName);
      addIf('firstName', firstName);
    }
    if (lastName != null && lastName.trim().isNotEmpty) {
      addIf('last_name', lastName);
      addIf('lastName', lastName);
    }
    if (email != null && email.trim().isNotEmpty) {
      addIf('email', email);
    }
    if (phone != null && phone.trim().isNotEmpty) {
      addIf('phone', phone);
    }

    // Also include a nested `tenant` object which some backends expect
    final tenantObj = <String, dynamic>{
      if (payload.containsKey('first_name')) 'first_name': payload['first_name'],
      if (payload.containsKey('last_name')) 'last_name': payload['last_name'],
      if (payload.containsKey('email')) 'email': payload['email'],
      if (payload.containsKey('phone')) 'phone': payload['phone'],
    };
    if (tenantObj.isNotEmpty) payload['tenant'] = tenantObj;

    dev.log('[HTTP] PATCH $uri body=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.patch(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to approve registration',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        // Changed from NotificationDto.fromJson to Notification.fromJson
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      // Changed from NotificationDto.fromJson to Notification.fromJson
      return Notification.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  // PATCH /api/notifications/{id}/reject-registration
  Future<Notification> rejectRegistration({
    required int notificationId,
  }) async {
    final uri = buildUri(Endpoints.notificationRejectRegistration(notificationId));
    final headers = await buildHeaders();

    dev.log('[HTTP] PATCH $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.patch(uri, headers: headers),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to reject registration',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        // Changed from NotificationDto.fromJson to Notification.fromJson
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      // Changed from NotificationDto.fromJson to Notification.fromJson
      return Notification.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  // PUT /api/notifications/{id}
  Future<Notification> update({
    required int id,
    String? title,
    String? message,
    bool? isRead,
    String? type,
  }) async {
    final uri = buildUri(Endpoints.notificationById(id));
    final headers = await buildHeaders();

    final payload = <String, dynamic>{};
    void addIfNonNull(String key, dynamic value) {
      if (value != null) payload[key] = value;
    }

    addIfNonNull('title', title);
    addIfNonNull('message', message);
    addIfNonNull('is_read', isRead);
    addIfNonNull('type', type);

    dev.log('[HTTP] PUT $uri body=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.put(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to update notification',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        // Changed from NotificationDto.fromJson to Notification.fromJson
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      // Changed from NotificationDto.fromJson to Notification.fromJson
      return Notification.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  // DELETE /api/notifications/{id}
  Future<void> delete(int id) async {
    final uri = buildUri(Endpoints.notificationById(id));
    final headers = await buildHeaders();

    dev.log('[HTTP] DELETE $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.delete(uri, headers: headers),
    );

    HttpErrorHandler.handleDeleteResponse(
      response,
      'Failed to delete notification',
    );
  }

  // NEW: Helper method to create registration notification
  Future<Notification> createRegistrationNotification({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String identityImageUrl,
    int? landlordId,
    int? chatId,
  }) async {
    final uri = buildUri(Endpoints.notifications);
    final headers = await buildHeaders();

    // Create registration payload
    final registrationPayload = RegistrationPayload(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      identityImageUrl: identityImageUrl,
    );

    final payload = <String, dynamic>{
      'notification_type': 'registration',
      if (landlordId != null) 'landlord_id': landlordId,
      if (chatId != null) 'chat_id': chatId,
      'payload': registrationPayload.toJson(),
    };

    dev.log('[HTTP] POST $uri body=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to create registration notification',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return Notification.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  // NEW: Helper method to create payment/meter reading notification
  Future<Notification> createMeterReadingNotification({
    required int landlordId,
    required int chatId,
    required String waterMeter,
    required String waterAccuracy,
    required String electricityMeter,
    required String electricityAccuracy,
    required String waterImage,
    required String electricityImage,
  }) async {
    final uri = buildUri(Endpoints.notifications);
    final headers = await buildHeaders();

    // Create meter reading payload
    final meterPayload = MeterReadingPayload(
      landlordId: landlordId,
      chatId: chatId,
      waterMeter: waterMeter,
      waterAccuracy: waterAccuracy,
      electricityMeter: electricityMeter,
      electricityAccuracy: electricityAccuracy,
      waterImage: waterImage,
      electricityImage: electricityImage,
    );

    final payload = <String, dynamic>{
      'notification_type': 'meter_reading',
      'landlord_id': landlordId,
      'chat_id': chatId,
      'payload': meterPayload.toJson(),
    };

    dev.log('[HTTP] POST $uri body=${jsonEncode(payload)}');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers, body: jsonEncode(payload)),
    );

    final decoded = HttpErrorHandler.handleResponse(
      response,
      'Failed to create meter reading notification',
    );

    if (decoded is Map<String, dynamic>) {
      if (decoded['data'] is Map<String, dynamic>) {
        return Notification.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return Notification.fromJson(decoded);
    }
    throw Exception('Unexpected response format');
  }

  // POST /api/notifications/landlord/{landlord_id}/payment-reminders
  Future<void> sendPaymentRemindersToLandlord(int landlordId) async {
    final uri = buildUri(Endpoints.notificationsPaymentReminders(landlordId));
    final headers = await buildHeaders();

    dev.log('[HTTP] POST $uri');
    final response = await HttpErrorHandler.executeRequest(
      () => httpClient.post(uri, headers: headers),
    );

    // Will throw on non-success statuses
    HttpErrorHandler.handleResponse(
      response,
      'Failed to send payment reminders',
    );
  }
}