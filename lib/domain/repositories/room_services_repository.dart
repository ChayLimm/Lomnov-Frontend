import 'package:app/domain/models/settings/service_model.dart';

/// Abstract repository interface for room services operations.
///
/// Defines the contract for room services (facilities) CRUD operations
/// that must be implemented by concrete repository classes.
abstract class RoomServicesRepository {
  /// Fetches all services attached to a room.
  ///
  /// Returns a list of [ServiceModel] objects for the specified [roomId].
  /// Throws an [Exception] if the fetch operation fails.
  Future<List<ServiceModel>> fetchRoomServices(int roomId);

  /// Attaches a service to a room.
  ///
  /// Returns a [ServiceModel] representing the attached service.
  /// Throws an [Exception] if the operation fails.
  Future<ServiceModel> attachService(int roomId, int serviceId);

  /// Detaches a service from a room.
  ///
  /// Throws an [Exception] if the operation fails.
  Future<void> detachService(int roomId, int serviceId);
}
