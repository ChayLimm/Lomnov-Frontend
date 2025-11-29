import 'package:app/domain/models/home_model/invoice_status.dart';

/// Domain model for Invoice/Receipt
/// Represents a rental payment invoice
class Invoice {
  final int id;
  final String tenantName;
  final String roomNumber;
  final double amount;
  final InvoiceStatus status;
  final DateTime dueDate;
  final DateTime? paidDate;

  const Invoice({
    required this.id,
    required this.tenantName,
    required this.roomNumber,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidDate,
  });

  /// Check if the invoice is overdue
  bool get isOverdue {
    if (status == InvoiceStatus.paid) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// Get days until due (negative if overdue)
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Get days overdue (0 if not overdue)
  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  /// Create a copy with updated values
  Invoice copyWith({
    int? id,
    String? tenantName,
    String? roomNumber,
    double? amount,
    InvoiceStatus? status,
    DateTime? dueDate,
    DateTime? paidDate,
  }) {
    return Invoice(
      id: id ?? this.id,
      tenantName: tenantName ?? this.tenantName,
      roomNumber: roomNumber ?? this.roomNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invoice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tenantName == other.tenantName &&
          roomNumber == other.roomNumber &&
          amount == other.amount &&
          status == other.status &&
          dueDate == other.dueDate &&
          paidDate == other.paidDate;

  @override
  int get hashCode =>
      id.hashCode ^
      tenantName.hashCode ^
      roomNumber.hashCode ^
      amount.hashCode ^
      status.hashCode ^
      dueDate.hashCode ^
      paidDate.hashCode;

  @override
  String toString() {
    return 'Invoice(id: $id, tenantName: $tenantName, roomNumber: $roomNumber, amount: $amount, status: $status, dueDate: $dueDate)';
  }
}
