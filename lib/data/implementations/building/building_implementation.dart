import 'package:app/domain/models/building_model.dart';
import 'package:app/domain/repositories/building_repository.dart';
import 'package:app/domain/services/buildings/fetch_service.dart';
import 'package:app/domain/services/buildings/mutation_service.dart';

/// Implementation of [BuildingRepository] using building services.
/// 
/// This class provides concrete implementations of building operations
/// by delegating to [BuildingFetchService] and [BuildingMutationService].
class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingFetchService _fetchService = BuildingFetchService();
  final BuildingMutationService _mutationService = BuildingMutationService();

  @override
  Future<List<BuildingModel>> fetchBuildings() async {
    return await _fetchService.fetchBuildings();
  }

  @override
  Future<BuildingModel> fetchBuildingById(int id) async {
    return await _fetchService.fetchBuildingById(id);
  }

  @override
  Future<BuildingModel> createBuilding({
    int? landlordId,
    required String name,
    required String address,
    String? imageUrl,
    required int floor,
    required int unit,
  }) async {
    return await _mutationService.createBuilding(
      landlordId: landlordId,
      name: name,
      address: address,
      imageUrl: imageUrl,
      floor: floor,
      unit: unit,
    );
  }

  @override
  Future<BuildingModel> updateBuilding({
    required int id,
    int? landlordId,
    String? name,
    String? address,
    String? imageUrl,
    int? floor,
    int? unit,
  }) async {
    return await _mutationService.updateBuilding(
      id: id,
      landlordId: landlordId,
      name: name,
      address: address,
      imageUrl: imageUrl,
      floor: floor,
      unit: unit,
    );
  }

  @override
  Future<void> deleteBuilding(int id) async {
    await _mutationService.deleteBuilding(id);
  }
}
