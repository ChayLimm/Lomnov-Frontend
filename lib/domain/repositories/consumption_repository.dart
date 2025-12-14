import 'package:app/domain/models/consumption/consumption.dart';

abstract class ConsumptionRepository {
  Future<List<Consumption>> fetchByRoom(int roomId);
  Future<Consumption> create({
    required int roomId,
    required int serviceId,
    required double endReading,
    String? photoUrl,
    double? consumption,
  });
  Future<Consumption> update({
    required int id,
    int? roomId,
    int? serviceId,
    double? endReading,
    String? photoUrl,
    double? consumption,
  });
  Future<void> delete(int id);
}
