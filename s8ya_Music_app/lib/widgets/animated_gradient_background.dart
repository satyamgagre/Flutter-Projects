import 'package:flutter/material.dart';

/// Animated gradient background for the player screen.
///
/// Colors can be dynamically driven by the album art palette.
class AnimatedGradientBackground extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Widget child;

  const AnimatedGradientBackground({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.8),
            secondaryColor.withValues(alpha: 0.6),
            Colors.black.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
