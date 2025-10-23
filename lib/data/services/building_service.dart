import 'package:app/domain/models/building_model.dart';
import 'package:app/domain/services/buildings/fetch_service.dart';
import 'package:app/domain/services/buildings/mutation_service.dart';

/// Facade that keeps the public API stable while delegating to smaller files.
class BuildingService {
  final _fetch = BuildingFetchService();
  final _mutate = BuildingMutationService();

  Future<List<BuildingModel>> fetchBuildings() => _fetch.fetchBuildings();
  Future<BuildingModel> fetchBuildingById(int id) => _fetch.fetchBuildingById(id);

  Future<void> deleteBuilding(int id) => _mutate.deleteBuilding(id);
  Future<BuildingModel> updateBuilding({
    required int id,
    int? landlordId,
    String? name,
    String? address,
    String? imageUrl,
    int? floor,
    int? unit,
  }) => _mutate.updateBuilding(
        id: id,
        landlordId: landlordId,
        name: name,
        address: address,
        imageUrl: imageUrl,
        floor: floor,
        unit: unit,
      );

  Future<BuildingModel> createBuilding({
    int? landlordId,
    required String name,
    required String address,
    String? imageUrl,
    required int floor,
    required int unit,
  }) => _mutate.createBuilding(
        landlordId: landlordId,
        name: name,
        address: address,
        imageUrl: imageUrl,
        floor: floor,
        unit: unit,
      );
}
