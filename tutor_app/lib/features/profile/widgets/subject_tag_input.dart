import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

//Lets tutors type a subject and add it as a chip. Tap the X on any chip to remove it.


class SubjectTagInput extends StatefulWidget {
  final List<String> subjects;
  final ValueChanged<List<String>> onChanged;

  const SubjectTagInput({
    super.key,
    required this.subjects,
    required this.onChanged,
  });

  @override
  State<SubjectTagInput> createState() => _SubjectTagInputState();
}

class _SubjectTagInputState extends State<SubjectTagInput> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();

  void _add() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (widget.subjects.contains(text)) return;
    final updated = [...widget.subjects, text];
    widget.onChanged(updated);
    _ctrl.clear();
    _focus.requestFocus();
  }

  void _remove(String subject) {
    final updated = widget.subjects.where((s) => s != subject).toList();
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing subject chips
        if (widget.subjects.isNotEmpty) ...[
          Wrap(
            spacing: 8, runSpacing: 8,
            children: widget.subjects.map((s) => _SubjectChip(
              label: s,
              onRemove: () => _remove(s),
            )).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Add new subject field
        Row(children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey900),
              decoration: InputDecoration(
                hintText: 'e.g. Calculus, Python…',
                hintStyle: AppTextStyles.bodyMedium,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _add,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.white, size: 20),
            ),
          ),
        ]),
      ],
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _SubjectChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: AppTextStyles.labelLarge
                .copyWith(color: AppColors.primary)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close_rounded,
              size: 14, color: AppColors.primary),
        ),
      ]),
    );
  }
}
