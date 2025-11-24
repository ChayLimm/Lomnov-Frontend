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
	final String name;
	final double price;
	final String status;

	const RoomModel({
		required this.id,
		required this.name,
		required this.price,
		required this.status,
	});
}

