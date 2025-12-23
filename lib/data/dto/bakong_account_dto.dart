import 'package:app/domain/models/bakong_account/bakong_account.dart';

class BakongAccountDto {
  final int id;
  final int landlordId;
  final String bakongId;
  final String bakongName;
  final String? bakongLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BakongAccountDto({
    required this.id,
    required this.landlordId,
    required this.bakongId,
    required this.bakongName,
    this.bakongLocation,
    this.createdAt,
    this.updatedAt,
  });

  factory BakongAccountDto.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is double) return v.toInt();
      return 0;
    }

    return BakongAccountDto(
      id: toInt(json['id']),
      landlordId: toInt(json['landlord_id'] ?? json['landlordId']),
      bakongId: (json['bakong_id'] ?? '') as String,
      bakongName: (json['bakong_name'] ?? '') as String,
      bakongLocation: json['bakong_location'] as String?,
      createdAt: toDate(json['created_at']),
      updatedAt: toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'landlord_id': landlordId,
        'bakong_id': bakongId,
        'bakong_name': bakongName,
        'bakong_location': bakongLocation,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  BakongAccount toDomain() => BakongAccount(
        id: id,
        landlordId: landlordId,
        bakongId: bakongId,
        bakongName: bakongName,
        bakongLocation: bakongLocation,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static List<BakongAccountDto> fromJsonList(List<dynamic> list) {
    return list.map((e) => BakongAccountDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
