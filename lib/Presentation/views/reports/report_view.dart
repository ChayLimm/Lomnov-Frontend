// ignore_for_file: control_flow_in_finally

import 'package:flutter/material.dart';
import 'package:app/Presentation/themes/app_colors.dart';
import 'package:app/domain/models/report.dart';
import 'package:app/data/services/reports_service.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final ReportsService _service = ApiReportsService();
  String _period = 'Monthly';
  ReportData? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fetch after first frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await _service.fetchReport(period: _period);
      if (!mounted) return;
      setState(() {
        _data = d;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load report';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _changePeriod(String p) {
    if (_period == p) return;
    setState(() => _period = p);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final listChildren = <Widget>[
      _Filters(
        period: _period,
        onPeriodChanged: _changePeriod,
      ),
      const SizedBox(height: 8),
      if (_loading && _data == null) ...[
        const SizedBox(height: 120),
        const Center(child: CircularProgressIndicator()),
      ] else if (_error != null && _data == null) ...[
        _ErrorView(message: _error!, onRetry: _fetch),
      ] else ...[
        _Card(child: _TotalIncome(data: _data)),
        const SizedBox(height: 10),
        _Card(child: _Breakdown(data: _data)),
      ],
      const SizedBox(height: 24),
    ];

    // If an error occurs while we still have data, show a banner above
    if (_error != null && _data != null) {
      listChildren.insert(1, Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _InlineError(message: _error!, onRetry: _fetch),
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Report'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share_outlined))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: listChildren,
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final String period; final ValueChanged<String> onPeriodChanged;
  const _Filters({required this.period, required this.onPeriodChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: All filter (placeholder)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0,4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('All', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Right: Period toggle + Export
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0,4))],
          ),
          child: Row(children: [
            _ChipButton(
              label: 'Monthly',
              selected: period == 'Monthly',
              onTap: () => onPeriodChanged('Monthly'),
            ),
            _ChipButton(
              label: 'Yearly',
              selected: period == 'Yearly',
              onTap: () => onPeriodChanged('Yearly'),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: (){},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.dividerColor.withValues(alpha: 0.8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export'),
            )
          ]),
        )
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _ChipButton({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : AppColors.tertiaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child; const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0,4))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message; final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message; final Future<void> Function() onRetry;
  const _InlineError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          )
        ],
      ),
    );
  }
}

class _TotalIncome extends StatelessWidget {
  final ReportData? data; const _TotalIncome({required this.data});
  @override
  Widget build(BuildContext context) {
    final d = data;
    final income = d?.totalIncome ?? 2262.50;
    final paid = d?.paid ?? 22; final total = d?.totalInvoices ?? 30;
    final ratio = total > 0 ? paid/total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Total Income', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(_fmtCurrency(income), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 140, height: 140,
            child: Stack(alignment: Alignment.center, children: [
              _Donut(progress: ratio),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$paid/$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Paid', style: TextStyle(fontSize: 10, color: AppColors.textSecondary))
              ])
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.dividerColor.withValues(alpha: 0.8)),
        const SizedBox(height: 8),
        ...((d?.legends ?? [
          LegendItem('Building A', '11/15 Paid', const Color(0xFF4D8CE4)),
          LegendItem('Building B', '11/15 Paid', const Color(0xFF22369D)),
        ])).map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: e.color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(child: Text(e.name, style: const TextStyle(fontSize: 12))),
              Text(e.value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
            ],
          ),
        ))
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  final ReportData? data; const _Breakdown({required this.data});
  @override
  Widget build(BuildContext context) {
    final rows = data?.breakdown ?? [
      BreakdownItem('Room Total', 1230.00, 22),
      BreakdownItem('Services Total', 1230.00, 22),
      BreakdownItem('Water Total', 1230.00, 22),
      BreakdownItem('Electricity Total', 1230.00, 22),
    ];

    final total = rows.fold<double>(0, (p, e) => p + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Breakdown', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...rows.map((e) => _BreakdownRow(item: e, total: total)),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final BreakdownItem item; final double total; const _BreakdownRow({required this.item, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (item.amount/total).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(_fmtCurrency(item.amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text('${item.rooms} Rooms', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: AppColors.dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        )
      ]),
    );
  }
}

class _Donut extends StatelessWidget { final double progress; const _Donut({required this.progress});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(progress: progress),
      size: const Size.square(140),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress; _DonutPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width/2, size.height/2);
    const stroke = 14.0;
    final r = (size.width - stroke)/2;
    final bg = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);

    final fg = Paint()
      ..shader = AppColors.primaryGradient.createShader(Rect.fromCircle(center: c, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final start = -3.14159/2;
    final sweep = 6.28318 * progress.clamp(0.0, 1.0);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false, fg);
  }
  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}

String _fmtCurrency(double v) {
  // Simple currency formatting without intl
  return '\$${v.toStringAsFixed(2)}';
}
