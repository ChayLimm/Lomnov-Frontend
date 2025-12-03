/// Domain model for Room Type (settings)
class RoomTypeModel {
  final int id;
  final String roomTypeName;
  final String? description;

  const RoomTypeModel({
    required this.id,
    required this.roomTypeName,
    this.description,
  });

  RoomTypeModel copyWith({int? id, String? roomTypeName, String? description}) {
    return RoomTypeModel(
      id: id ?? this.id,
      roomTypeName: roomTypeName ?? this.roomTypeName,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'RoomTypeModel(id: $id, roomTypeName: $roomTypeName)';
}
