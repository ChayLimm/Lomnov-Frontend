// lib/data/dto/setting_dto.dart
import 'package:app/domain/models/setting.dart';

class SettingDto {
  final int id;
  final int userId;
  final String? generalRules;
  final String? contractRules;
  final double khrCurrency;
  final double finePerDay;
  final int fineAfter;
  final double tax;
  final double? waterPrice;
  final double? electricityPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SettingDto({
    required this.id,
    required this.userId,
    this.generalRules,
    this.contractRules,
    required this.khrCurrency,
    required this.finePerDay,
    required this.fineAfter,
    required this.tax,
    this.waterPrice,
    this.electricityPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory SettingDto.fromJson(Map<String, dynamic> json) {
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

    return SettingDto(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      generalRules: json['general_rules'],
      contractRules: json['contract_rules'],
      khrCurrency: toDouble(json['khr_currency']),
      finePerDay: toDouble(json['fine_per_day']),
      fineAfter: json['fine_after'] as int,
      tax: toDouble(json['tax']),
      waterPrice: toDouble(json['water_price']),
      electricityPrice: toDouble(json['electricity_price']),
      createdAt: toDate(json['created_at']),
      updatedAt: toDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'general_rules': generalRules,
        'contract_rules': contractRules,
        'khr_currency': khrCurrency,
        'fine_per_day': finePerDay,
        'fine_after': fineAfter,
        'tax': tax,
        'water_price': waterPrice,
        'electricity_price': electricityPrice,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  Setting toDomain() => Setting(
        id: id,
        userId: userId,
        generalRules: generalRules,
        contractRules: contractRules,
        khrCurrency: khrCurrency,
        finePerDay: finePerDay,
        fineAfter: fineAfter,
        tax: tax,
        waterPrice: waterPrice,
        electricityPrice: electricityPrice,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}