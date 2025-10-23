import 'package:app/domain/models/building_model.dart';

/// Abstract repository interface for building operations.
/// 
/// Defines the contract for building-related CRUD operations
/// that must be implemented by concrete repository classes.
abstract class BuildingRepository {
  /// Fetches all buildings.
  /// 
  /// Returns a list of [BuildingModel] objects.
  /// Throws an [Exception] if the fetch operation fails.
  Future<List<BuildingModel>> fetchBuildings();

  /// Fetches a single building by its ID.
  /// 
  /// Returns a [BuildingModel] for the specified [id].
  /// Throws an [Exception] if the building is not found or fetch fails.
  Future<BuildingModel> fetchBuildingById(int id);

  /// Creates a new building.
  /// 
  /// Returns a [BuildingModel] representing the newly created building.
  /// Throws an [Exception] if creation fails.
  Future<BuildingModel> createBuilding({
    int? landlordId,
    required String name,
    required String address,
    String? imageUrl,
    required int floor,
    required int unit,
  });

  /// Updates an existing building.
  /// 
  /// Returns a [BuildingModel] representing the updated building.
  /// Throws an [Exception] if the update fails.
  Future<BuildingModel> updateBuilding({
    required int id,
    int? landlordId,
    String? name,
    String? address,
    String? imageUrl,
    int? floor,
    int? unit,
  });

  /// Deletes a building by its ID.
  /// 
  /// Throws an [Exception] if deletion fails.
  Future<void> deleteBuilding(int id);
}
