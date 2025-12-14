import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/data/dto/landlord_dto.dart';
import 'package:app/data/dto/room_dto.dart';

/// Data Transfer Object for Building
/// Handles JSON serialization/deserialization for API communication
class BuildingDto {
  final int id;
  final int landlordId;
  final String name;
  final String address;
  final String imageUrl;
  final int floor;
  final int unit;
  final LandlordDto? landlord;
  final List<RoomDto> rooms;

  const BuildingDto({
    required this.id,
    required this.landlordId,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.floor,
    required this.unit,
    this.landlord,
    this.rooms = const [],
  });

  /// Create from API JSON response
  factory BuildingDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    int _toInt(dynamic v, {int defaultValue = 0}) {
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? defaultValue;
      return defaultValue;
    }
    return BuildingDto(
      id: _toInt(data['id']),
      landlordId: _toInt(data['landlord_id'] ?? data['landlordId']),
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['image_url'] ?? data['imageUrl'] ?? '',
      floor: _toInt(data['floor']),
      unit: _toInt(data['unit']),
      landlord: data['landlord'] != null
          ? LandlordDto.fromJson(data['landlord'] as Map<String, dynamic>)
          : null,
      rooms: (data['rooms'] as List?)
              ?.map((e) => RoomDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'landlord_id': landlordId,
    'name': name,
    'address': address,
    'image_url': imageUrl,
    'floor': floor,
    'unit': unit,
    'landlord': landlord?.toJson(),
    'rooms': rooms.map((e) => e.toJson()).toList(),
  };

  /// Convert DTO to domain model
  BuildingModel toDomain() {
    return BuildingModel(
      id: id,
      landlordId: landlordId,
      name: name,
      address: address,
      imageUrl: imageUrl,
      floor: floor,
      unit: unit,
      landlord: landlord?.toDomain(),
      rooms: rooms.map((e) => e.toDomain()).toList(),
    );
  }

  /// Create DTO from domain model
  factory BuildingDto.fromDomain(BuildingModel domain) {
    return BuildingDto(
      id: domain.id,
      landlordId: domain.landlordId,
      name: domain.name,
      address: domain.address,
      imageUrl: domain.imageUrl,
      floor: domain.floor,
      unit: domain.unit,
      landlord: domain.landlord != null 
          ? LandlordDto.fromDomain(domain.landlord!)
          : null,
      rooms: domain.rooms.map((e) => RoomDto.fromDomain(e)).toList(),
    );
  }

  /// Create list of DTOs from JSON array
  static List<BuildingDto> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => BuildingDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Convert list of DTOs to domain models
  static List<BuildingModel> toDomainList(List<BuildingDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}