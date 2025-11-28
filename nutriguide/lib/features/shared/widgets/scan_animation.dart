// To avoid duplication, you can either:
// 1. Move the code from features/photos/presentation/widgets/scan_animation.dart to here.
// 2. Export the photo feature widget here (if architecture permits).

// For clean architecture, moving the widget here is preferred.
// Assuming the code from Category 25 is moved here:

import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';

class SharedScanAnimation extends StatefulWidget {
  const SharedScanAnimation({super.key});

  @override
  State<SharedScanAnimation> createState() => _SharedScanAnimationState();
}

class _SharedScanAnimationState extends State<SharedScanAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment: Alignment(0, -1 + (2 * _animation.value)),
              child: Container(
                height: 3,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
