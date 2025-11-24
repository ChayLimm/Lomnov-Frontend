import 'package:app/data/dto/building_dto.dart';
import 'package:app/data/services/buildings_service/fetch_service.dart';
import 'package:app/data/services/buildings_service/mutation_service.dart';


class BuildingService {
  final _fetch = BuildingFetchService();
  final _mutate = BuildingMutationService();

  /// Fetch buildings, optionally for a specific landlord.
  Future<List<BuildingDto>> fetchBuildings({int? landlordId}) =>
      _fetch.fetchBuildingsForLandlord(landlordId: landlordId);
  Future fetchBuildingById(int id) =>
      _fetch.fetchBuildingById(id);

  Future<void> deleteBuilding(int id) => _mutate.deleteBuilding(id);
  Future<BuildingDto> updateBuilding({
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

  Future<BuildingDto> createBuilding({
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
