import 'package:app/Presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';

class StatusItem {
  final String label;
  final int count;
  final Color color;
  final double? spacing;
  final Color? backgroundColor;
  final TextStyle? countStyle;
  final TextStyle? labelStyle;
  final Widget? trailing;

  StatusItem({
    required this.label,
    required this.count,
    required this.color,
    this.spacing,
    this.backgroundColor,
    this.countStyle,
    this.labelStyle,
    this.trailing,
  });
}

class StatusCard extends StatelessWidget {
  final StatusItem item;
  const StatusCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: item.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.only(left: 0, right: 12, top: 10, bottom: 10),
      child: Row(
        children: [
          // Left status color strip with rounded right edge
          Container(
            width: 6,
            height: double.infinity,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
          SizedBox(width: item.spacing ?? 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.count}',
                  style: item.countStyle ?? const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                // const SizedBox(height: 4),
                Text(
                  item.label,
                  style: item.labelStyle ?? const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ],
            ),
          ),
          if (item.trailing != null) ...[
            const SizedBox(width: 8),
            item.trailing!,
          ]
        ],
      ),
    );
  }
}
