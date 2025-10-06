import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../domain/cores/constants/app_constants.dart';

class ProgressLoader extends StatelessWidget {
  final double width;
  final double height;
  final bool centered;
  final bool fullscreen;
  final String? message;
  final Color? color;

  const ProgressLoader({
    super.key,
    this.width = 80,
    this.height = 80,
    this.centered = true,
    this.fullscreen = true,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget loader = Shimmer(
      duration: AppConstants.mediumAnimation,
      interval: const Duration(seconds: 0),
      color: color ?? theme.colorScheme.primary.withValues(alpha: 0.3),
      colorOpacity: 0.3,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: fullscreen
          ? Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[400],
              ),
            )
          : Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
    );

    if (fullscreen) {
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color.fromRGBO(0, 0, 0, 0.15), // Updated to avoid deprecated .withOpacity
            ),
          ),
          Positioned.fill(
            child: Center(child: loader),
          ),
        ],
      );
    }

    return centered ? Center(child: loader) : loader;
  }
}
