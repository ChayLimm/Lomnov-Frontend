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

	const BuildingModel({
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
}

class LandlordModel {
	final int id;
	final String name;
	final String email;

	const LandlordModel({
		required this.id,
		required this.name,
		required this.email,
	});
}

class RoomModel {
	final int id;
	final int buildingId;
	final int roomTypeId;
	final String roomNumber;
	final double price;
	final String barcode;
	final String floor;
	final String status;
	final Map<String, dynamic>? building; // raw nested building payload (optional)
	final Map<String, dynamic>? roomType; // raw nested room_type payload (optional)
	final List<dynamic> contracts;
	final dynamic currentContract;
	final String? createdAt;
	final String? updatedAt;

	const RoomModel({
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

  void operator [](String other) {}
}

