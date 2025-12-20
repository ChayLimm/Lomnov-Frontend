import 'package:app/domain/models/consumption/consumption.dart';

class ConsumptionDto {
  final int id;
  final int roomId;
  final int? serviceId;
  final double endReading;
  final String photoUrl;
  final double consumption;
  final String type; // Added type field
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final ServiceSummaryDto? service;

  const ConsumptionDto({
    required this.id,
    required this.roomId,
    this.serviceId,
    required this.endReading,
    required this.photoUrl,
    required this.consumption,
    required this.type, // Added to constructor
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.service,
  });

  factory ConsumptionDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime? toDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    int? _toIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return ConsumptionDto(
      id: (json['id'] ?? 0) is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      roomId: (json['room_id'] ?? json['roomId'] ?? 0) is int
          ? (json['room_id'] ?? json['roomId']) as int
          : int.tryParse('${json['room_id'] ?? json['roomId']}') ?? 0,
      serviceId: _toIntNullable(json['service_id'] ?? json['serviceId']),
      endReading: toDouble(json['end_reading'] ?? json['endReading']),
      photoUrl: json['photo_url'] ?? json['photoUrl'] ?? '',
      consumption: toDouble(json['consumption']),
      type: json['type'] ?? 'water', // Default to water if not provided
      createdAt: toDate(json['created_at'] ?? json['createdAt']),
      updatedAt: toDate(json['updated_at'] ?? json['updatedAt']),
      deletedAt: toDate(json['deleted_at'] ?? json['deletedAt']),
      service: json['service'] is Map<String, dynamic>
          ? ServiceSummaryDto.fromJson(json['service'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_id': roomId,
        'service_id': serviceId,
        'end_reading': endReading,
        'photo_url': photoUrl,
        'consumption': consumption,
        'type': type, // Added to JSON
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'service': service?.toJson(),
      };

  Consumption toDomain() => Consumption(
        id: id,
        roomId: roomId,
        serviceId: serviceId,
        endReading: endReading,
        photoUrl: photoUrl,
        consumption: consumption,
        type: type, // Pass type to domain model
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        service: service?.toDomain(),
      );

  static List<ConsumptionDto> fromJsonList(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ConsumptionDto.fromJson(e))
        .toList();
  }

  static List<Consumption> toDomainList(List<ConsumptionDto> dtos) {
    return dtos.map((e) => e.toDomain()).toList();
  }
}
class ServiceSummaryDto {
  final int id;
  final String name;
  final double unitPrice;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? unitName;
  final String? serviceName;
  final int? landlordId;

  const ServiceSummaryDto({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.unitName,
    this.serviceName,
    this.landlordId,
  });

  factory ServiceSummaryDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime? toDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    int? toIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    return ServiceSummaryDto(
      id: (json['id'] ?? 0) is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      unitPrice: toDouble(json['unit_price'] ?? json['unitPrice']),
      description: json['description'] ?? '',
      createdAt: toDate(json['created_at'] ?? json['createdAt']),
      updatedAt: toDate(json['updated_at'] ?? json['updatedAt']),
      deletedAt: toDate(json['deleted_at'] ?? json['deletedAt']),
      unitName: json['unit_name'] ?? json['unitName'],
      serviceName: json['service_name'] ?? json['serviceName'],
      landlordId: toIntNullable(json['landlord_id'] ?? json['landlordId']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit_price': unitPrice,
        'description': description,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'unit_name': unitName,
        'service_name': serviceName,
        'landlord_id': landlordId,
      };

  ServiceSummary toDomain() => ServiceSummary(
        id: id,
        name: name,
        unitPrice: unitPrice,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        unitName: unitName,
        serviceName: serviceName,
        landlordId: landlordId,
      );
}
