import 'package:flutter/material.dart';

/// Global app background that paints background.png behind all pages.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool addOverlay;
  const AppBackground({super.key, required this.child, this.addOverlay = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.asset(
          'lib/assets/images/background.png',
          fit: BoxFit.cover,
        ),
        if (addOverlay)
          Container(
            // Subtle overlay to improve text legibility on bright backgrounds
            color: Colors.white.withValues(alpha: 0.05),
          ),
        // Page content
        child,
      ],
    );
  }
}
