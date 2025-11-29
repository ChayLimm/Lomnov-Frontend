/// Invoice status categories for the dashboard
enum InvoiceStatus { 
  unpaid, 
  pending, 
  paid, 
  delay 
}

/// Extension methods for InvoiceStatus
extension InvoiceStatusExtension on InvoiceStatus {
  /// Get the display name of the status
  String get displayName {
    switch (this) {
      case InvoiceStatus.unpaid:
        return 'Unpaid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.delay:
        return 'Delayed';
    }
  }

  /// Parse status from string
  static InvoiceStatus fromString(String status) {
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case 'paid':
        return InvoiceStatus.paid;
      case 'unpaid':
        return InvoiceStatus.unpaid;
      case 'delay':
      case 'delayed':
      case 'overdue':
        return InvoiceStatus.delay;
      case 'pending':
      default:
        return InvoiceStatus.pending;
    }
  }
}
