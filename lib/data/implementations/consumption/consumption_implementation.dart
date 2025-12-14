import 'package:app/data/services/consumptions_service/fetch_service.dart';
import 'package:app/data/services/consumptions_service/mutation_service.dart';
import 'package:app/domain/models/consumption/consumption.dart';
import 'package:app/domain/repositories/consumption_repository.dart';
import 'package:app/data/dto/consumption_dto.dart';

class ConsumptionRepositoryImpl implements ConsumptionRepository {
  final ConsumptionsFetchService _fetchService = ConsumptionsFetchService();
  final ConsumptionsMutationService _mutationService = ConsumptionsMutationService();

  @override
  Future<List<Consumption>> fetchByRoom(int roomId) async {
    final dtos = await _fetchService.fetchByRoom(roomId);
    return ConsumptionDto.toDomainList(dtos);
  }

  @override
  Future<Consumption> create({
    required int roomId,
    required int serviceId,
    required double endReading,
    String? photoUrl,
    double? consumption,
  }) async {
    final dto = await _mutationService.create(
      roomId: roomId,
      serviceId: serviceId,
      endReading: endReading,
      photoUrl: photoUrl,
      consumption: consumption,
    );
    return dto.toDomain();
  }

  @override
  Future<Consumption> update({
    required int id,
    int? roomId,
    int? serviceId,
    double? endReading,
    String? photoUrl,
    double? consumption,
  }) async {
    final dto = await _mutationService.update(
      id: id,
      roomId: roomId,
      serviceId: serviceId,
      endReading: endReading,
      photoUrl: photoUrl,
      consumption: consumption,
    );
    return dto.toDomain();
  }

  @override
  Future<void> delete(int id) async {
    await _mutationService.delete(id);
  }
}
