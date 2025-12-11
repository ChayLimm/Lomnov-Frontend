import 'package:app/data/services/contract_service/contract_service.dart';
import 'package:app/domain/models/contract/contract_model.dart';
import 'package:app/domain/repositories/contract_repository.dart';

/// Implementation of [ContractRepository] using contract API.
///
/// This class provides concrete implementations of contract operations
/// by delegating to [ContractService].
class ContractRepositoryImpl implements ContractRepository {
  final ContractService _service = ContractService();

  @override
  Future<ContractModel?> fetchActiveContract(int roomId) async {
    final dto = await _service.fetchActiveContract(roomId);
    return dto?.toDomain();
  }
}
