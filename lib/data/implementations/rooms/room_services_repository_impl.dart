import 'package:app/data/services/rooms_service/room_services_service.dart';
import 'package:app/domain/models/settings/service_model.dart';
import 'package:app/domain/repositories/room_services_repository.dart';

/// Implementation of [RoomServicesRepository] using room services API.
///
/// This class provides concrete implementations of room services operations
/// by delegating to [RoomServicesService].
class RoomServicesRepositoryImpl implements RoomServicesRepository {
  final RoomServicesService _service = RoomServicesService();

  @override
  Future<List<ServiceModel>> fetchRoomServices(int roomId) async {
    final dtos = await _service.fetchRoomServices(roomId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<ServiceModel> attachService(int roomId, int serviceId) async {
    final dto = await _service.attachService(roomId, serviceId);
    return dto.toDomain();
  }

  @override
  Future<void> detachService(int roomId, int serviceId) async {
    await _service.detachService(roomId, serviceId);
  }
}
