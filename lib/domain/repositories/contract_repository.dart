import 'package:app/domain/models/contract/contract_model.dart';

/// Abstract repository interface for contract operations.
///
/// Defines the contract for room contract operations
/// that must be implemented by concrete repository classes.
abstract class ContractRepository {
  /// Fetches the active contract for a specific room.
  ///
  /// Returns a [ContractModel] for the specified [roomId].
  /// Returns null if no active contract exists.
  /// Throws an [Exception] if the fetch operation fails.
  Future<ContractModel?> fetchActiveContract(int roomId);
}
