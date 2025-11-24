import 'package:app/domain/models/building_model/building_model.dart';

/// Data Transfer Object for Room
/// Handles JSON serialization/deserialization for API communication
class RoomDto {
  final int id;
  final String name;
  final double price;
  final String status;

  const RoomDto({
    required this.id,
    required this.name,
    required this.price,
    required this.status,
  });

  /// Create from API JSON response
  factory RoomDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final priceValue = data['price'];
    return RoomDto(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      price: priceValue is num ? priceValue.toDouble() : 0.0,
      status: data['status'] ?? '',
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'status': status,
  };

  /// Convert DTO to domain model
  RoomModel toDomain() {
    return RoomModel(
      id: id,
      name: name,
      price: price,
      status: status,
    );
  }

  /// Create DTO from domain model
  factory RoomDto.fromDomain(RoomModel domain) {
    return RoomDto(
      id: domain.id,
      name: domain.name,
      price: domain.price,
      status: domain.status,
    );
  }

  /// Create list of DTOs from JSON array
  static List<RoomDto> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => RoomDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Convert list of DTOs to domain models
  static List<RoomModel> toDomainList(List<RoomDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}