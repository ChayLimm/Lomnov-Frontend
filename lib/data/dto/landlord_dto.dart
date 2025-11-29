import 'package:app/domain/models/building_model/building_model.dart';

/// Data Transfer Object for Landlord
/// Handles JSON serialization/deserialization for API communication
class LandlordDto {
  final int id;
  final String name;
  final String email;

  const LandlordDto({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Create from API JSON response
  factory LandlordDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return LandlordDto(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  /// Convert DTO to domain model
  LandlordModel toDomain() {
    return LandlordModel(
      id: id,
      name: name,
      email: email,
    );
  }

  /// Create DTO from domain model
  factory LandlordDto.fromDomain(LandlordModel domain) {
    return LandlordDto(
      id: domain.id,
      name: domain.name,
      email: domain.email,
    );
  }

  /// Create list of DTOs from JSON array
  static List<LandlordDto> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => LandlordDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Convert list of DTOs to domain models
  static List<LandlordModel> toDomainList(List<LandlordDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}