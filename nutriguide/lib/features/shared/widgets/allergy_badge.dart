import 'package:flutter/material.dart';
import 'package:nutriguide/core/theme/colors.dart';

enum BadgeType { safety, warning, info }

class AllergyBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final VoidCallback? onTap;

  const AllergyBadge({
    super.key,
    required this.text,
    this.type = BadgeType.info,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case BadgeType.safety:
        bgColor = const Color(0xFFF0FDF4); // Light Green
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case BadgeType.warning:
        bgColor = const Color(0xFFFEF2F2); // Light Red
        textColor = AppColors.error;
        icon = Icons.warning_amber_rounded;
        break;
      case BadgeType.info:
        bgColor = const Color(0xFFEFF6FF); // Light Blue
        textColor = AppColors.info;
        icon = Icons.info_outline;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
