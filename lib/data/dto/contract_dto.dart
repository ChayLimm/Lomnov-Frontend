import 'package:app/data/dto/tenant_dto.dart';
import 'package:app/domain/models/contract/contract_model.dart';

/// Data Transfer Object for contract information.
class ContractDto {
  final int id;
  final int roomId;
  final int tenantId;
  final String startDate;
  final String? endDate;
  final String depositAmount;
  final String status;
  final String createdAt;
  final String updatedAt;
  final TenantDto tenant;

  ContractDto({
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

  factory ContractDto.fromJson(Map<String, dynamic> json) {
    return ContractDto(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      tenantId: json['tenant_id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      depositAmount: json['deposit_amount'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      tenant: TenantDto.fromJson(json['tenant'] as Map<String, dynamic>),
    );
  }

  /// Converts DTO to domain model.
  ContractModel toDomain() {
    return ContractModel(
      id: id,
      roomId: roomId,
      tenantId: tenantId,
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      depositAmount: double.parse(depositAmount),
      status: status,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      tenant: tenant.toDomain(),
    );
  }
}
