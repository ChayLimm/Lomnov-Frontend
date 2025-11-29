import 'package:app/data/services/buildings_service/fetch_service.dart';
import 'package:app/data/services/buildings_service/mutation_service.dart';
import 'package:app/domain/models/building_model/building_model.dart';
import 'package:app/domain/repositories/building_repository.dart';

/// Implementation of [BuildingRepository] using building services.
///
/// This class provides concrete implementations of building operations
/// by delegating to [BuildingFetchService] and [BuildingMutationService].
class BuildingRepositoryImpl implements BuildingRepository {
  final BuildingFetchService _fetchService = BuildingFetchService();
  final BuildingMutationService _mutationService = BuildingMutationService();

  @override
  Future<List<BuildingModel>> fetchBuildings({int? landlordId}) async {
    final dtos = await _fetchService.fetchBuildingsForLandlord(
      landlordId: landlordId,
    );
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<BuildingModel> fetchBuildingById(int id) async {
    final dto = await _fetchService.fetchBuildingById(id);
    return dto.toDomain();
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
    final dto = await _mutationService.createBuilding(
      landlordId: landlordId,
      name: name,
      address: address,
      imageUrl: imageUrl,
      floor: floor,
      unit: unit,
    );
    return dto.toDomain();
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
    final dto = await _mutationService.updateBuilding(
      id: id,
      landlordId: landlordId,
      name: name,
      address: address,
      imageUrl: imageUrl,
      floor: floor,
      unit: unit,
    );
    return dto.toDomain();
  }

  @override
  Future<void> deleteBuilding(int id) async {
    await _mutationService.deleteBuilding(id);
  }
}
