import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, outlined, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(disabled),
    );
  }

  Widget _buildButton(bool disabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: disabled ? AppColors.grey200 : AppColors.primary,
            foregroundColor: disabled ? AppColors.grey400 : AppColors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: _buildChild(disabled ? AppColors.grey400 : AppColors.white),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: disabled ? AppColors.grey200 : AppColors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: _buildChild(disabled ? AppColors.grey400 : AppColors.primary),
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: _buildChild(disabled ? AppColors.grey400 : AppColors.primary),
        );
      case AppButtonVariant.danger:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          ),
          child: _buildChild(AppColors.white),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: AppTextStyles.labelLarge.copyWith(color: color)),
        ],
      );
    }

    return Text(label,
        style: AppTextStyles.labelLarge.copyWith(color: color));
  }
}