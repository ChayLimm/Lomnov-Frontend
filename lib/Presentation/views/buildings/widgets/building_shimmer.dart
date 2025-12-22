import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BuildingShimmer extends StatelessWidget {
  const BuildingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade200;
    final highlight = Colors.grey.shade300;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 700),
      child: Container(
        color: const Color(0xFFF8F8F8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 18, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Container(width: 160, height: 14, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Container(width: 120, height: 14, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 80, height: 28, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
                      const SizedBox(width: 8),
                      Container(width: 60, height: 28, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
