// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:app/Presentation/themes/app_colors.dart';

/// A reusable confirmation dialog that matches the app's avatar-style
/// confirmation UI (icon/avatar + full-width Cancel/Delete buttons).
class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String cancelLabel;
  final String confirmLabel;
  final bool confirmDestructive;
  final IconData? avatarIcon;
  final double avatarRadius;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    this.content,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.confirmDestructive = false,
    this.avatarIcon = Icons.help_outline,
    this.avatarRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 22),
      title: Column(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primaryColor.withOpacity(0.12),
            child: Icon(avatarIcon, color: AppColors.primaryColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      content: content,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    foregroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmDestructive ? AppColors.errorColor : AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
