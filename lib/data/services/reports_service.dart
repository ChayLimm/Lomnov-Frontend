import 'dart:convert';
import 'package:app/domain/models/report.dart';
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:flutter/material.dart';

abstract class ReportsService {
  Future<ReportData> fetchReport({required String period});
}

class MockReportsService implements ReportsService {
  @override
  Future<ReportData> fetchReport({required String period}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ReportData(
      totalIncome: 2262.50,
      paid: 22,
      totalInvoices: 30,
      legends: const [
        LegendItem('Building A', '11/15 Paid', Color(0xFF4D8CE4)),
        LegendItem('Building B', '11/15 Paid', Color(0xFF22369D)),
      ],
      breakdown: const [
        BreakdownItem('Room Total', 1230.00, 22),
        BreakdownItem('Services Total', 1230.00, 22),
        BreakdownItem('Water Total', 1230.00, 22),
        BreakdownItem('Electricity Total', 1230.00, 22),
      ],
    );
  }
}

class ApiReportsService extends ApiBase implements ReportsService {
  @override
  Future<ReportData> fetchReport({required String period}) async {
    final uri = buildUri(Endpoints.reports);
    final headers = await buildHeaders();

    final res = await HttpErrorHandler.executeRequest(
      () => httpClient.get(uri, headers: headers),
    );
    final dynamic decoded = HttpErrorHandler.handleResponse(
      res,
      'Failed to load report',
    );
    final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
        ? decoded
        : json.decode(res.body) as Map<String, dynamic>;

    // Parse total income
    final totalIncomeObj = (jsonMap['total_income'] as Map?) ?? const {};
    final double totalIncome = (totalIncomeObj['total_income'] as num?)?.toDouble() ?? 0.0;

    // Derive paid/totalInvoices if available; fallback to 0
    final unpaid = (jsonMap['unpaid'] as Map?) ?? const {};
    final int unpaidRooms = (unpaid['unpaid_rooms'] as num?)?.toInt() ?? 0;
    final int unpaidServices = (unpaid['unpaid_services'] as num?)?.toInt() ?? 0;
    // Without precise fields, approximate totals as sum and paid as 0
    final int totalInvoices = unpaidRooms + unpaidServices;
    final int paid = 0;

    // Legends from service_details
    final List<dynamic> serviceDetails = (jsonMap['service_details'] as List?) ?? const [];
    final legends = serviceDetails.map((e) {
      final m = e as Map<String, dynamic>;
      final name = (m['name'] ?? '').toString();
      final totalAmount = (m['total_amount'] as num?)?.toDouble() ?? 0.0;
      // Display total amount; color palette fallback
      return LegendItem(name, _fmtCurrency(totalAmount), const Color(0xFF4D8CE4));
    }).toList();

    // Breakdown
    final breakdownObj = (jsonMap['breakdown'] as Map?) ?? const {};
    final roomTotal = (breakdownObj['room_total'] as num?)?.toDouble() ?? 0.0;
    final serviceTotal = (breakdownObj['service_total'] as num?)?.toDouble() ?? 0.0;
    final consumption = (breakdownObj['consumption'] as Map?) ?? const {};
    final waterTotal = (consumption['water_total_m3'] as num?)?.toDouble() ?? 0.0;
    final electricityTotal = (consumption['electricity_total_kwh'] as num?)?.toDouble() ?? 0.0;
    final breakdown = <BreakdownItem>[
      BreakdownItem('Room Total', roomTotal, 0),
      BreakdownItem('Services Total', serviceTotal, 0),
      BreakdownItem('Water Total', waterTotal, 0),
      BreakdownItem('Electricity Total', electricityTotal, 0),
    ];

    return ReportData(
      totalIncome: totalIncome,
      paid: paid,
      totalInvoices: totalInvoices,
      legends: legends,
      breakdown: breakdown,
    );
  }
}

String _fmtCurrency(double v) => '\$${v.toStringAsFixed(2)}';
