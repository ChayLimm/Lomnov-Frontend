import 'dart:convert';

class MeterReadingPayload {
  final int? landlordId;
  final int? chatId;
  final String? waterMeter;
  final String? waterAccuracy;
  final String? electricityMeter;
  final String? electricityAccuracy;
  final String? waterImage;
  final String? electricityImage;

  MeterReadingPayload({
    this.landlordId,
    this.chatId,
    this.waterMeter,
    this.waterAccuracy,
    this.electricityMeter,
    this.electricityAccuracy,
    this.waterImage,
    this.electricityImage,
  });

  factory MeterReadingPayload.fromJson(Map<String, dynamic> json) {
    return MeterReadingPayload(
      landlordId: _extractInt(json, 'landlord_id'),
      chatId: _extractInt(json, 'chat_id'),
      waterMeter: _extractString(json, 'water_meter'),
      waterAccuracy: _extractString(json, 'water_accuracy'),
      electricityMeter: _extractString(json, 'electricity_meter'),
      electricityAccuracy: _extractString(json, 'electricity_accuracy'),
      waterImage: _extractString(json, 'water_image'),
      electricityImage: _extractString(json, 'electricity_image'),
    );
  }

  static MeterReadingPayload? fromDynamic(dynamic data) {
    if (data == null) return null;
    
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return MeterReadingPayload.fromJson(decoded);
        }
        return null;
      } catch (e) {
        print('Error parsing meter reading payload: $e');
        return null;
      }
    } else if (data is Map<String, dynamic>) {
      return MeterReadingPayload.fromJson(data);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (landlordId != null) data['landlord_id'] = landlordId;
    if (chatId != null) data['chat_id'] = chatId;
    if (waterMeter != null) data['water_meter'] = waterMeter;
    if (waterAccuracy != null) data['water_accuracy'] = waterAccuracy;
    if (electricityMeter != null) data['electricity_meter'] = electricityMeter;
    if (electricityAccuracy != null) data['electricity_accuracy'] = electricityAccuracy;
    if (waterImage != null) data['water_image'] = waterImage;
    if (electricityImage != null) data['electricity_image'] = electricityImage;
    
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  MeterReadingPayload copyWith({
    int? landlordId,
    int? chatId,
    String? waterMeter,
    String? waterAccuracy,
    String? electricityMeter,
    String? electricityAccuracy,
    String? waterImage,
    String? electricityImage,
  }) {
    return MeterReadingPayload(
      landlordId: landlordId ?? this.landlordId,
      chatId: chatId ?? this.chatId,
      waterMeter: waterMeter ?? this.waterMeter,
      waterAccuracy: waterAccuracy ?? this.waterAccuracy,
      electricityMeter: electricityMeter ?? this.electricityMeter,
      electricityAccuracy: electricityAccuracy ?? this.electricityAccuracy,
      waterImage: waterImage ?? this.waterImage,
      electricityImage: electricityImage ?? this.electricityImage,
    );
  }

  @override
  String toString() {
    return 'MeterReadingPayload(landlordId: $landlordId, chatId: $chatId)';
  }

  static int? _extractInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static String? _extractString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    return value.toString();
  }
}