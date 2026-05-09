import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SubjectFilterChips extends StatelessWidget {
  final List<String> subjects;
  final String selected;
  final ValueChanged<String> onSelected;

  const SubjectFilterChips({
    super.key,
    required this.subjects,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final subject  = subjects[i];
          final isActive = subject == selected;
          return GestureDetector(
            onTap: () => onSelected(subject),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.white,
                borderRadius: AppRadius.fullAll,
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.grey200,
                  width: 1.5,
                ),
              ),
              child: Text(subject,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isActive ? AppColors.white : AppColors.grey600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
