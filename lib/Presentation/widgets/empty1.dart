import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? illustration;
  final EdgeInsetsGeometry? padding;

  const EmptyState({
    super.key,
    this.title,
    this.subtitle,
    this.illustration,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration ??
                Icon(
                  Icons.hourglass_empty,
                  color: theme.colorScheme.primary,
                  size: 80,
                ),
            const SizedBox(height: 24),
            Text(
              title ?? 'There is No Data',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle ??
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}