import 'package:flutter/material.dart';

class ReportData {
  final double totalIncome;
  final int paid;
  final int totalInvoices;
  final List<LegendItem> legends;
  final List<BreakdownItem> breakdown;
  const ReportData({
    required this.totalIncome,
    required this.paid,
    required this.totalInvoices,
    required this.legends,
    required this.breakdown,
  });
}

class LegendItem {
  final String name;
  final String value;
  final Color color;
  const LegendItem(this.name, this.value, this.color);
}

class BreakdownItem {
  final String title;
  final double amount;
  final int rooms;
  const BreakdownItem(this.title, this.amount, this.rooms);
}
