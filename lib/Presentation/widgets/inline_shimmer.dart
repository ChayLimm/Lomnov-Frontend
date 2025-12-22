import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class InlineShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? radius;
  const InlineShimmer({super.key, this.width = double.infinity, this.height = 12, this.radius});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade200;
    final highlight = Colors.grey.shade300;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: radius ?? BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class CardShimmer extends StatelessWidget {
  final double height;
  const CardShimmer({super.key, this.height = 72});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade200;
    final highlight = Colors.grey.shade300;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  InlineShimmer(height: 14),
                  SizedBox(height: 6),
                  InlineShimmer(height: 12)
                ],
              ),
            ),
            Container(width: 80, height: 28, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(10))),
          ],
        ),
      ),
    );
  }
}
