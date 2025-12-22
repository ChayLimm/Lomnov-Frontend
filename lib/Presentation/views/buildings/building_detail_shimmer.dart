import 'package:flutter/material.dart';
import 'package:app/Presentation/widgets/inline_shimmer.dart';

/// Shimmer used on the Building Detail screen while the building data loads.
/// It mirrors the header + rounded white content area used on the real screen.
class BuildingDetailShimmer extends StatelessWidget {
  const BuildingDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // header placeholder
          SizedBox(
            height: 230,
            width: double.infinity,
            child: Container(color: Colors.grey.shade300),
          ),
          // content area
          Positioned.fill(
            top: 230 - 20,
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    InlineShimmer(height: 22, width: 220),
                    SizedBox(height: 8),
                    InlineShimmer(height: 14, width: 140),
                    SizedBox(height: 12),
                    InlineShimmer(height: 14, width: 220),
                    SizedBox(height: 16),
                    InlineShimmer(height: 14, width: 220),
                    SizedBox(height: 12),
                    CardShimmer(height: 80),
                    SizedBox(height: 12),
                    CardShimmer(height: 80),
                    SizedBox(height: 12),
                    InlineShimmer(height: 14, width: 120),
                  ],
                ),
              ),
            ),
          ),
          // top-left back button placeholder so layout doesn't jump
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
