import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final bool isPositive;
  final bool isNegative;

  const StatBadge({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.isPositive = false,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.primaryLight;
    Color bgColor = AppColors.primary.withOpacity(0.12);

    if (isPositive) {
      textColor = AppColors.bullGreen;
      bgColor = AppColors.bullGreenBg;
    } else if (isNegative) {
      textColor = AppColors.bearRed;
      bgColor = AppColors.bearRedBg;
    } else if (color != null) {
      textColor = color!;
      bgColor = color!.withOpacity(0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
