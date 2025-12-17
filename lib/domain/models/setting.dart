// lib/domain/models/setting/setting.dart
class Setting {
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

  const Setting({
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
}