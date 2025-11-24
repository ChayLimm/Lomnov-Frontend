import 'package:app/domain/models/home_model/invoice_status.dart';

/// Domain model for Dashboard Summary
/// Represents the overview data displayed on the home screen
class DashboardSummary {
  final String userName;
  final String? avatarUrl;
  final int totalInvoices;
  final int paidInvoices;
  final double totalIncome;
  final DateTime month;
  final Map<InvoiceStatus, int> counts;

  const DashboardSummary({
    required this.userName,
    this.avatarUrl,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.totalIncome,
    required this.month,
    required this.counts,
  });

  /// Calculate the ratio of paid invoices to total invoices
  double get paidRatio => totalInvoices == 0 ? 0 : paidInvoices / totalInvoices;

  /// Get count for a specific invoice status
  int getCountForStatus(InvoiceStatus status) => counts[status] ?? 0;

  /// Create a copy with updated values
  DashboardSummary copyWith({
    String? userName,
    String? avatarUrl,
    int? totalInvoices,
    int? paidInvoices,
    double? totalIncome,
    DateTime? month,
    Map<InvoiceStatus, int>? counts,
  }) {
    return DashboardSummary(
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      paidInvoices: paidInvoices ?? this.paidInvoices,
      totalIncome: totalIncome ?? this.totalIncome,
      month: month ?? this.month,
      counts: counts ?? this.counts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardSummary &&
          runtimeType == other.runtimeType &&
          userName == other.userName &&
          avatarUrl == other.avatarUrl &&
          totalInvoices == other.totalInvoices &&
          paidInvoices == other.paidInvoices &&
          totalIncome == other.totalIncome &&
          month == other.month;

  @override
  int get hashCode =>
      userName.hashCode ^
      avatarUrl.hashCode ^
      totalInvoices.hashCode ^
      paidInvoices.hashCode ^
      totalIncome.hashCode ^
      month.hashCode;

  @override
  String toString() {
    return 'DashboardSummary(userName: $userName, totalInvoices: $totalInvoices, paidInvoices: $paidInvoices, totalIncome: $totalIncome, month: $month)';
  }
}
