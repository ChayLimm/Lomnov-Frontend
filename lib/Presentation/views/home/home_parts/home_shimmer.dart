import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade200;
    final highlight = Colors.grey.shade300;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton (avatar + name)
                Row(
                  children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Line(width: 40, height: 10),
                          const SizedBox(height: 6),
                          _Line(width: 120, height: 16),
                        ],
                      ),
                    ),
                    Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 12),
                _Line(width: 100, height: 14), // "Overview"
                const SizedBox(height: 10),

                // Rounded overview + statuses section 
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFEDEEF3), borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overview card 
                      Row(
                        children: [
                          Container(width: 96, height: 96, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Line(width: 80, height: 12),
                                const SizedBox(height: 8),
                                _Line(width: 120, height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 6),

                      // Status grid skeleton 
                      const _StatusesGridSkeleton(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _Line(width: 120, height: 14), // "Quick Action"
                const SizedBox(height: 12),

                // Quick actions skeleton (3 cards)
                Row(
                  children: [
                    Expanded(child: _CardSkeleton()),
                    const SizedBox(width: 12),
                    Expanded(child: _CardSkeleton()),
                    const SizedBox(width: 12),
                    Expanded(child: _CardSkeleton()),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Receipts skeleton placed below
          const _ReceiptsSkeleton(),
        ],
      ),
    );
  }
}

class _StatusesGridSkeleton extends StatelessWidget {
  const _StatusesGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const crossAxisCount = 3;
      const crossAxisSpacing = 8.0;
      const mainSpacing = 10.0;
      const childAspectRatio = 2.0;
      final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
      final itemHeight = itemWidth / childAspectRatio;

      Widget tile({bool trailing = false}) => Container(
            padding: const EdgeInsets.only(left: 0, right: 12, top: 10, bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Line(width: 24, height: 12),
                      SizedBox(height: 4),
                      _Line(width: 40, height: 10),
                    ],
                  ),
                ),
                if (trailing) ...[
                  const SizedBox(width: 8),
                  Container(width: 110, height: 28, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                ],
              ],
            ),
          );

      return Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: 3,
            itemBuilder: (_, __) => tile(),
          ),
          const SizedBox(height: mainSpacing),
          SizedBox(width: double.infinity, height: itemHeight, child: tile(trailing: true)),
        ],
      );
    });
  }
}

class _ReceiptsSkeleton extends StatelessWidget {
  const _ReceiptsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Line(width: 80, height: 14),
          const SizedBox(height: 12),
          Row(
            children: const [
              _Chip(width: 60),
              SizedBox(width: 8),
              _Chip(width: 80),
              SizedBox(width: 8),
              _Chip(width: 60),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Line(width: 120, height: 14),
                        SizedBox(height: 6),
                        _Line(width: 80, height: 12),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const _Line(width: 60, height: 14),
                      const SizedBox(height: 6),
                      Container(width: 50, height: 18, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 96, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(16)));
  }
}

class _Chip extends StatelessWidget {
  final double width;
  const _Chip({required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: 28, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)));
  }
}

class _Line extends StatelessWidget {
  final double width;
  final double height;
  const _Line({required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, color: Colors.grey.shade300);
  }
}