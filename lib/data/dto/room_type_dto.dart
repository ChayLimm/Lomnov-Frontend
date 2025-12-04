import 'package:app/domain/models/settings/room_type_model.dart';

class RoomTypeDto {
  final int id;
  final String roomTypeName;
  final String? description;

  const RoomTypeDto({
    required this.id,
    required this.roomTypeName,
    this.description,
  });

  factory RoomTypeDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return RoomTypeDto(
      id: data['id'] ?? 0,
      roomTypeName: data['room_type_name'] ?? data['roomTypeName'] ?? data['name'] ?? '',
      description: data['description'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'room_type_name': roomTypeName,
        'description': description,
      };

  RoomTypeModel toDomain() => RoomTypeModel(
        id: id,
        roomTypeName: roomTypeName,
        description: description,
      );

  factory RoomTypeDto.fromDomain(RoomTypeModel m) => RoomTypeDto(
        id: m.id,
        roomTypeName: m.roomTypeName,
        description: m.description,
      );

  static List<RoomTypeDto> fromJsonList(List<dynamic> list) {
    return list.map((e) => RoomTypeDto.fromJson(e as Map<String, dynamic>)).toList();
  }
}
