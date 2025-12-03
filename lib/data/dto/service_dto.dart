import 'package:app/domain/models/settings/service_model.dart';

/// DTO for Service API payloads
class ServiceDto {
  final int id;
  final String name;
  final double? unitPrice;
  final String? description;

  const ServiceDto({
    required this.id,
    required this.name,
    this.unitPrice,
    this.description,
  });

  factory ServiceDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final priceRaw = data['unit_price'] ?? data['unitPrice'];
    double? parsedPrice;
    if (priceRaw is num) parsedPrice = priceRaw.toDouble();
    else if (priceRaw is String) parsedPrice = double.tryParse(priceRaw);

    return ServiceDto(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      unitPrice: parsedPrice,
      description: data['description'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit_price': unitPrice,
        'description': description,
      };

  ServiceModel toDomain() => ServiceModel(
        id: id,
        name: name,
        unitPrice: unitPrice,
        description: description,
      );

  factory ServiceDto.fromDomain(ServiceModel s) => ServiceDto(
        id: s.id,
        name: s.name,
        unitPrice: s.unitPrice,
        description: s.description,
      );

  static List<ServiceDto> fromJsonList(List<dynamic> list) {
    return list.map((e) => ServiceDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
