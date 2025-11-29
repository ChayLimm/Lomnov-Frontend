import 'package:app/domain/models/building_model/building_model.dart';

/// Data Transfer Object for Room — maps the API shape to a DTO
class RoomDto {
  final int id;
  final int buildingId;
  final int roomTypeId;
  final String roomNumber;
  final double price;
  final String barcode;
  final String floor;
  final String status;
  final Map<String, dynamic>? building;
  final Map<String, dynamic>? roomType;
  final List<dynamic> contracts;
  final dynamic currentContract;
  final String? createdAt;
  final String? updatedAt;

  const RoomDto({
    required this.id,
    required this.buildingId,
    required this.roomTypeId,
    required this.roomNumber,
    required this.price,
    required this.barcode,
    required this.floor,
    required this.status,
    this.building,
    this.roomType,
    this.contracts = const [],
    this.currentContract,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from API JSON response (handles items wrapped in `data` or raw)
  factory RoomDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final priceValue = data['price'];
    double parsedPrice;
    if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    } else {
      parsedPrice = 0.0;
    }

    return RoomDto(
      id: data['id'] ?? 0,
      buildingId: data['building_id'] ?? data['buildingId'] ?? 0,
      roomTypeId: data['room_type_id'] ?? data['roomTypeId'] ?? 0,
      roomNumber: (data['room_number'] ?? data['name'] ?? '').toString(),
      price: parsedPrice,
      barcode: (data['barcode'] ?? '').toString(),
      floor: (data['floor'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      building: data['building'] is Map ? Map<String, dynamic>.from(data['building']) : null,
      roomType: data['room_type'] is Map ? Map<String, dynamic>.from(data['room_type']) : null,
      contracts: (data['contracts'] as List?) ?? const [],
      currentContract: data['current_contract'],
      createdAt: data['created_at']?.toString(),
      updatedAt: data['updated_at']?.toString(),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'building_id': buildingId,
    'room_type_id': roomTypeId,
    'room_number': roomNumber,
    'price': price,
    'barcode': barcode,
    'floor': floor,
    'status': status,
    'building': building,
    'room_type': roomType,
    'contracts': contracts,
    'current_contract': currentContract,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  /// Convert DTO to domain model
  RoomModel toDomain() {
    return RoomModel(
      id: id,
      buildingId: buildingId,
      roomTypeId: roomTypeId,
      roomNumber: roomNumber,
      price: price,
      barcode: barcode,
      floor: floor,
      status: status,
      building: building,
      roomType: roomType,
      contracts: contracts,
      currentContract: currentContract,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create DTO from domain model
  factory RoomDto.fromDomain(RoomModel domain) {
    return RoomDto(
      id: domain.id,
      buildingId: domain.buildingId,
      roomTypeId: domain.roomTypeId,
      roomNumber: domain.roomNumber,
      price: domain.price,
      barcode: domain.barcode,
      floor: domain.floor,
      status: domain.status,
      building: domain.building,
      roomType: domain.roomType,
      contracts: domain.contracts,
      currentContract: domain.currentContract,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt,
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