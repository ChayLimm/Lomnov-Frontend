import 'package:flutter/material.dart';

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
    Color background;
    Color foreground;
    OutlinedBorder shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

    switch (type) {
      case ButtonType.primary:
        background = theme.colorScheme.primary;
        foreground = theme.colorScheme.onPrimary;
        break;
      case ButtonType.secondary:
        background = theme.colorScheme.secondary;
        foreground = theme.colorScheme.onSecondary;
        break;
      case ButtonType.tertiary:
        background = Colors.transparent;
        foreground = theme.colorScheme.primary;
        break;
    }

    ButtonStyle style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => enabled ? background : theme.disabledColor,
      ),
      foregroundColor: WidgetStateProperty.all(foreground),
      shape: WidgetStateProperty.all(shape),
      padding: WidgetStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      minimumSize: WidgetStateProperty.all(Size(width ?? 0, height ?? 0)),
      elevation: WidgetStateProperty.all(type == ButtonType.tertiary ? 0 : 2),
    );

    Widget button;
    if (type == ButtonType.tertiary) {
      button = TextButton(
        style: style,
        onPressed: enabled ? onPressed : null,
        child: child,
      );
    } else {
      button = ElevatedButton(
        style: style,
        onPressed: enabled ? onPressed : null,
        child: child,
      );
    }

    return button;
  }
}