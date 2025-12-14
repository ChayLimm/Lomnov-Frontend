class Consumption {
	final int id;
	final int roomId;
	final int serviceId;
	final double endReading;
	final String photoUrl;
	final double consumption;
	final DateTime? createdAt;
	final DateTime? updatedAt;
	final DateTime? deletedAt;
	final ServiceSummary? service; // optional nested service summary

	const Consumption({
		required this.id,
		required this.roomId,
		required this.serviceId,
		required this.endReading,
		required this.photoUrl,
		required this.consumption,
		this.createdAt,
		this.updatedAt,
		this.deletedAt,
		this.service,
	});
}

class ServiceSummary {
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

	const ServiceSummary({
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
}
