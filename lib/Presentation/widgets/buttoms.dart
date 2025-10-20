import 'package:flutter/material.dart';
import 'package:app/Presentation/themes/app_colors.dart';

enum ButtonType { primary, secondary, tertiary }

class CustomButton extends StatelessWidget {
  final ButtonType type;
  final VoidCallback? onPressed;
  final Widget child;
  final bool enabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.child,
    this.type = ButtonType.primary,
    this.onPressed,
    this.enabled = true,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (type) {
      // Primary: match the filled "Add" button in buildings_view.dart
      case ButtonType.primary:
        return FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            minimumSize: Size(width ?? 0, height ?? 48),
          ),
          onPressed: enabled ? onPressed : null,
          child: child,
        );

      // Secondary: outlined pill like "available room" badge in BuildingCard
      case ButtonType.secondary:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primaryColor, width: 1),
            foregroundColor: AppColors.primaryColor,
            backgroundColor: Colors.transparent,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: Size(width ?? 0, height ?? (height ?? 0)),
            textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          onPressed: enabled ? onPressed : null,
          child: child,
        );

      // Tertiary: simple text button using primary color
      case ButtonType.tertiary:
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size(width ?? 0, height ?? 0),
          ),
          onPressed: enabled ? onPressed : null,
          child: child,
        );
    }
  }
}