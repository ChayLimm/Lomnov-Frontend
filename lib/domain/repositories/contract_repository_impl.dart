import 'package:app/domain/models/contract/contract_model.dart';
import 'package:app/domain/repositories/contract_repository.dart';
import 'package:app/data/services/contract_service/contract_service.dart';

class ContractRepositoryImpl implements ContractRepository {
  final ContractService _service;

  ContractRepositoryImpl(this._service);

  @override
  Future<ContractModel?> fetchActiveContract(int roomId) async {
    final dto = await _service.fetchActiveContract(roomId);
    if (dto == null) return null;
    return dto.toDomain();
  }

  Future<Map<String, dynamic>?> createContract(Map<String, dynamic> payload) async {
    return await _service.createContract(payload);
  }

  Future<Map<String, dynamic>?> updateContract(int id, Map<String, dynamic> payload) async {
    return await _service.updateContract(id, payload);
  }
}
