import 'package:app/domain/models/contract/tenant_model.dart';

/// Domain model representing an active contract.
class ContractModel {
  final int id;
  final int roomId;
  final int tenantId;
  final DateTime startDate;
  final DateTime? endDate;
  final double depositAmount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TenantModel tenant;

  ContractModel({
    required this.id,
    required this.roomId,
    required this.tenantId,
    required this.startDate,
    this.endDate,
    required this.depositAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.tenant,
  });

  bool get isActive => status.toLowerCase() == 'active';
}
