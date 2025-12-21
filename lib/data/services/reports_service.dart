import 'dart:convert';
import 'package:app/domain/models/report.dart';
import 'package:app/data/services/buildings_service/api_base.dart';
import 'package:app/data/services/http_error_handler.dart';
import 'package:app/data/endpoint/endpoints.dart';
import 'package:flutter/material.dart';

abstract class ReportsService {
  Future<ReportData> fetchReport({required String period, required int landlordId});
}

class MockReportsService implements ReportsService {
  @override
  Future<ReportData> fetchReport({required String period, required int landlordId}) async {
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
  Future<ReportData> fetchReport({required String period, required int landlordId}) async {
    final uri = buildUri(Endpoints.reportsByLandlord(landlordId));
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

    // Parse total income (tolerant to string or numeric values)
    final totalIncomeObj = (jsonMap['total_income'] as Map?) ?? const {};
    final double totalIncome = _toDouble(totalIncomeObj['total_income']);

    // Parse landlord id and unpaid amounts
    final int? parsedLandlordId = (jsonMap['landlord_id'] is int)
      ? (jsonMap['landlord_id'] as int)
      : (int.tryParse((jsonMap['landlord_id'] ?? '').toString()) );

    final unpaid = (jsonMap['unpaid'] as Map?) ?? const {};
    double unpaidRooms = _toDouble(unpaid['unpaid_rooms']);
    double unpaidServices = _toDouble(unpaid['unpaid_services']);
    // Without precise paid/total fields, keep as approximations
    final int totalInvoices = (unpaidRooms + unpaidServices).toInt();
    final int paid = 0;

    // Legends from service_details
    final List<dynamic> serviceDetails = (jsonMap['service_details'] as List?) ?? const [];
    final legends = serviceDetails.map((e) {
      final m = e as Map<String, dynamic>;
      final name = (m['name'] ?? '').toString();
      final totalAmount = _toDouble(m['total_amount']);
      // Display total amount; color palette fallback
      return LegendItem(name, _fmtCurrency(totalAmount), const Color(0xFF4D8CE4));
    }).toList();

    // Breakdown
    final breakdownObj = (jsonMap['breakdown'] as Map?) ?? const {};
    final roomTotal = _toDouble(breakdownObj['room_total']);
    final serviceTotal = _toDouble(breakdownObj['service_total']);
    final consumption = (breakdownObj['consumption'] as Map?) ?? const {};
    final waterTotal = _toDouble(consumption['water_total_m3']);
    final electricityTotal = _toDouble(consumption['electricity_total_kwh']);
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
      landlordId: parsedLandlordId,
      unpaidRooms: unpaidRooms,
      unpaidServices: unpaidServices,
    );
  }
}

String _fmtCurrency(double v) => '\$${v.toStringAsFixed(2)}';

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
