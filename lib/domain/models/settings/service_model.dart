/// Domain model representing a configurable service/fee
class ServiceModel {
  final int id;
  final String name;
  final double? unitPrice;
  final String? description;

  const ServiceModel({
    required this.id,
    required this.name,
    this.unitPrice,
    this.description,
  });

  ServiceModel copyWith({int? id, String? name, double? unitPrice, String? description}) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'ServiceModel(id: $id, name: $name, unitPrice: $unitPrice)';
}
