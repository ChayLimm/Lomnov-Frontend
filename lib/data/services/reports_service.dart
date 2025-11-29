import 'package:app/domain/models/report.dart';
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
