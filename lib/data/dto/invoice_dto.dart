import 'package:app/domain/models/home_model/invoice_model.dart';
import 'package:app/domain/models/home_model/invoice_status.dart';

/// Data Transfer Object for Invoice
/// Handles JSON serialization/deserialization for API communication
class InvoiceDto {
  final int id;
  final String tenantName;
  final String roomNumber;
  final double amount;
  final InvoiceStatus status;
  final DateTime dueDate;
  final DateTime? paidDate;

  const InvoiceDto({
    required this.id,
    required this.tenantName,
    required this.roomNumber,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidDate,
  });

  /// Create from API JSON response
  factory InvoiceDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Parse status
    final statusStr = (data['status'] ?? 'pending').toString();
    final status = InvoiceStatusExtension.fromString(statusStr);

    return InvoiceDto(
      id: data['id'] ?? 0,
      tenantName: data['tenant_name'] ?? data['tenantName'] ?? 'Unknown',
      roomNumber: data['room_number'] ?? data['roomNumber'] ?? 'N/A',
      amount: (data['amount'] ?? 0).toDouble(),
      status: status,
      dueDate: data['due_date'] != null 
          ? DateTime.parse(data['due_date'].toString())
          : DateTime.now(),
      paidDate: data['paid_date'] != null 
          ? DateTime.parse(data['paid_date'].toString())
          : null,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'tenant_name': tenantName,
    'room_number': roomNumber,
    'amount': amount,
    'status': status.name,
    'due_date': dueDate.toIso8601String(),
    'paid_date': paidDate?.toIso8601String(),
  };

  /// Convert DTO to domain model
  Invoice toDomain() {
    return Invoice(
      id: id,
      tenantName: tenantName,
      roomNumber: roomNumber,
      amount: amount,
      status: status,
      dueDate: dueDate,
      paidDate: paidDate,
    );
  }

  /// Create DTO from domain model
  factory InvoiceDto.fromDomain(Invoice domain) {
    return InvoiceDto(
      id: domain.id,
      tenantName: domain.tenantName,
      roomNumber: domain.roomNumber,
      amount: domain.amount,
      status: domain.status,
      dueDate: domain.dueDate,
      paidDate: domain.paidDate,
    );
  }
}
