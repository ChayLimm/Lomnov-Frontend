import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReportShimmer extends StatelessWidget {
  const ReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      period: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // TotalIncome placeholder 
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Container(width: 120, height: 220, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 120, height: 14, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 20, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 10, color: Colors.grey.shade300),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // summary blocks
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 80, height: 46, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 16, color: Colors.grey.shade300),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Breakdown  
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 120, maxHeight: 400),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}