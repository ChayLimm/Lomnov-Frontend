class BuildingModel {
	final int id;
	final int landlordId;
	final String name;
	final String address;
	final String imageUrl;
	final int floor;
	final int unit;
	final LandlordModel? landlord;
	final List<RoomModel> rooms;

	BuildingModel({
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

	factory BuildingModel.fromJson(Map<String, dynamic> json) {
		return BuildingModel(
			id: json['id'] ?? 0,
			landlordId: json['landlord_id'] ?? json['landlordId'] ?? 0,
			name: json['name'] ?? '',
			address: json['address'] ?? '',
			imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
			floor: json['floor'] ?? 0,
			unit: json['unit'] ?? 0,
			landlord: json['landlord'] != null
					? LandlordModel.fromJson(json['landlord'] as Map<String, dynamic>)
					: null,
			rooms: (json['rooms'] as List?)
							?.map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
							.toList() ??
					const [],
		);
	}

	Map<String, dynamic> toJson() {
		return {
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
	}

	static List<BuildingModel> fromJsonList(List<dynamic> list) {
		return list
				.map((e) => BuildingModel.fromJson(e as Map<String, dynamic>))
				.toList();
	}
}

class LandlordModel {
	final int id;
	final String name;
	final String email;

	LandlordModel({
		required this.id,
		required this.name,
		required this.email,
	});

	factory LandlordModel.fromJson(Map<String, dynamic> json) {
		return LandlordModel(
			id: json['id'] ?? 0,
			name: json['name'] ?? '',
			email: json['email'] ?? '',
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'email': email,
		};
	}
}

class RoomModel {
	final int id;
	final String name;
	final double price;
	final String status;

	RoomModel({
		required this.id,
		required this.name,
		required this.price,
		required this.status,
	});

	factory RoomModel.fromJson(Map<String, dynamic> json) {
		final priceValue = json['price'];
		return RoomModel(
			id: json['id'] ?? 0,
			name: json['name'] ?? '',
			price: priceValue is num ? priceValue.toDouble() : 0.0,
			status: json['status'] ?? '',
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'price': price,
			'status': status,
		};
	}
}

