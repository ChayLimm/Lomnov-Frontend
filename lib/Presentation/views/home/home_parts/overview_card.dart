import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:app/domain/models/home_model/dashboard_summary.dart';
import 'package:app/domain/utils/utils.dart';

class OverviewCard extends StatelessWidget {
  final DashboardSummary? summary;
  const OverviewCard({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    final paid = summary?.paidInvoices ?? 30;
    final total = summary?.totalInvoices ?? 40;
    final ratio = summary?.paidRatio ?? (total > 0 ? (paid / total) : 0.0);
    final income = summary?.totalIncome ?? 2262.50;
    final month = summary?.month ?? DateTime(2025, 10, 1);

    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('lib/assets/images/main_pic.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          Row(
            children: [
              ProgressRing(ratio: ratio, labelTop: 'Paid invoices', labelBottom: '$paid/$total'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(formatCurrency(income), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tertiaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(formatMonth(month), style: const TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  final double ratio;
  final String labelTop;
  final String labelBottom;
  const ProgressRing({required this.ratio, required this.labelTop, required this.labelBottom, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient circular progress implemented with CustomPaint
          SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _GradientProgressPainter(
                progress: ratio.clamp(0.0, 1.0),
                strokeWidth: 10,
                gradient: AppColors.primaryGradient,
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(labelTop, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(labelBottom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientProgressPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final double strokeWidth;
  final Gradient gradient;
  final Color backgroundColor;

  _GradientProgressPainter({required this.progress, required this.strokeWidth, required this.gradient, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Convert provided Gradient (likely LinearGradient) to SweepGradient for circular shader
    final colors = (gradient is LinearGradient) ? (gradient as LinearGradient).colors : [AppColors.primaryColor, AppColors.primaryColor];

    final sweep = SweepGradient(
      colors: colors,
      startAngle: 0.0,
      endAngle: math.pi * 2,
      transform: GradientRotation(-math.pi / 2),
    );

    final fgPaint = Paint()
      ..shader = sweep.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.gradient != gradient || oldDelegate.backgroundColor != backgroundColor || oldDelegate.strokeWidth != strokeWidth;
  }
}
