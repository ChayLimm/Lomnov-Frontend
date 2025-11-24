import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/models/home_model/invoice_status.dart';

/// Data Transfer Object for DashboardSummary


/// Handles JSON serialization/deserialization for API communication
class DashboardSummaryDto {
  final String userName;
  final String? avatarUrl;
  final int totalInvoices;
  final int paidInvoices;
  final double totalIncome;
  final DateTime month;
  final Map<InvoiceStatus, int> counts;

  const DashboardSummaryDto({
    required this.userName,
    this.avatarUrl,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.totalIncome,
    required this.month,
    required this.counts,
  });

  /// Create from API JSON response
  factory DashboardSummaryDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Parse counts/statuses
    Map<InvoiceStatus, int> countsMap = {};
    if (data['counts'] is Map) {
      final counts = data['counts'] as Map;
      countsMap = {
        InvoiceStatus.unpaid: counts['unpaid'] ?? counts['Unpaid'] ?? 0,
        InvoiceStatus.pending: counts['pending'] ?? counts['Pending'] ?? 0,
        InvoiceStatus.paid: counts['paid'] ?? counts['Paid'] ?? 0,
        InvoiceStatus.delay: counts['delay'] ?? counts['Delay'] ?? 0,
      };
    } else if (data['invoice_counts'] is Map) {
      final counts = data['invoice_counts'] as Map;
      countsMap = {
        InvoiceStatus.unpaid: counts['unpaid'] ?? 0,
        InvoiceStatus.pending: counts['pending'] ?? 0,
        InvoiceStatus.paid: counts['paid'] ?? 0,
        InvoiceStatus.delay: counts['delay'] ?? 0,
      };
    }

    return DashboardSummaryDto(
      userName: data['user_name'] ?? data['userName'] ?? 'User',
      avatarUrl: data['avatar_url'] ?? data['avatarUrl'],
      totalInvoices: data['total_invoices'] ?? data['totalInvoices'] ?? 0,
      paidInvoices: data['paid_invoices'] ?? data['paidInvoices'] ?? 0,
      totalIncome: (data['total_income'] ?? data['totalIncome'] ?? 0).toDouble(),
      month: data['month'] != null 
          ? DateTime.parse(data['month'].toString())
          : DateTime.now(),
      counts: countsMap,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'user_name': userName,
    'avatar_url': avatarUrl,
    'total_invoices': totalInvoices,
    'paid_invoices': paidInvoices,
    'total_income': totalIncome,
    'month': month.toIso8601String(),
    'counts': {
      'unpaid': counts[InvoiceStatus.unpaid] ?? 0,
      'pending': counts[InvoiceStatus.pending] ?? 0,
      'paid': counts[InvoiceStatus.paid] ?? 0,
      'delay': counts[InvoiceStatus.delay] ?? 0,
    },
  };

  /// Convert DTO to domain model
  DashboardSummary toDomain() {
    return DashboardSummary(
      userName: userName,
      avatarUrl: avatarUrl,
      totalInvoices: totalInvoices,
      paidInvoices: paidInvoices,
      totalIncome: totalIncome,
      month: month,
      counts: counts,
    );
  }

  /// Create DTO from domain model
  factory DashboardSummaryDto.fromDomain(DashboardSummary domain) {
    return DashboardSummaryDto(
      userName: domain.userName,
      avatarUrl: domain.avatarUrl,
      totalInvoices: domain.totalInvoices,
      paidInvoices: domain.paidInvoices,
      totalIncome: domain.totalIncome,
      month: domain.month,
      counts: domain.counts,
    );
  }
}
