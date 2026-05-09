import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Reusable empty state shown when a list has no items.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   message;
  final String?  buttonLabel;
  final VoidCallback? onButtonTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.xxlAll,
              ),
              child: Icon(icon,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 20),

            Text(title,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),

            Text(message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center),

            if (buttonLabel != null && onButtonTap != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: buttonLabel!,
                onPressed: onButtonTap,
                width: 200,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}