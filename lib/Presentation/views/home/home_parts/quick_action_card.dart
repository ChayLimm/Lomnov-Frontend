import 'package:app/presentation/themes/app_colors.dart';
import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const QuickActionCard({
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
