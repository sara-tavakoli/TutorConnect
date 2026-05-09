import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Call anywhere with context to show a consistent snackbar.
class SnackBarHelper {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.primary);

  static void _show(
      BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}