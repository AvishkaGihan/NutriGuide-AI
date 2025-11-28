import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';

class ScanAnimation extends StatefulWidget {
  const ScanAnimation({super.key});

  @override
  State<ScanAnimation> createState() => _ScanAnimationState();
}

class _ScanAnimationState extends State<ScanAnimation>
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
        // Dark overlay
        Container(color: Colors.black54),

        // Animated Scanner Line
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment: Alignment(0, -1 + (2 * _animation.value)),
              child: Container(
                height: 2,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            );
          },
        ),

        // Text Indicator
        const Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Identifying Ingredients...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
