import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CommonFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String heroTag;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final Widget? child;
  final bool mini;
  final bool extended;
  final String? label;

  const CommonFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.child,
    this.mini = false,
    this.extended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: iconColor ?? AppColors.white,
        icon: child ?? Icon(icon, size: size ?? 24),
        label: Text(
          label!,
          style: TextStyle(
            color: iconColor ?? AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: iconColor ?? AppColors.white,
      mini: mini,
      child: child ?? Icon(icon, size: size ?? 24),
    );
  }
}
