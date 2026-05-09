import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

//Lets tutors add and remove availability time slots

class AvailabilityEditor extends StatefulWidget {
  final List<String> slots;
  final ValueChanged<List<String>> onChanged;

  const AvailabilityEditor({
    super.key,
    required this.slots,
    required this.onChanged,
  });

  @override
  State<AvailabilityEditor> createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();

  void _add() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (widget.slots.contains(text)) return;
    widget.onChanged([...widget.slots, text]);
    _ctrl.clear();
    _focus.requestFocus();
  }

  void _remove(String slot) {
    widget.onChanged(widget.slots.where((s) => s != slot).toList());
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
        if (widget.slots.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.slots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final slot = widget.slots[i];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.grey400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(slot,
                        style: AppTextStyles.bodyMedium),
                  ),
                  GestureDetector(
                    onTap: () => _remove(slot),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.error),
                  ),
                ]),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
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
                hintText: 'e.g. Mon 2–3pm',
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