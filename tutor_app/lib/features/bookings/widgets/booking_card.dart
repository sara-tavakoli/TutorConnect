import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';

// A single booking row shows tutor/student name, slot, subject, and a coloured status badge. Tutors can confirm/cancel; students can cancel.

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isTutor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isTutor,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row : name + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isTutor ? booking.studentName : booking.tutorName,
                  style: AppTextStyles.titleMedium,
                ),
                _StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 8),
            // Subject + slot
            Row(children: [
              const Icon(Icons.menu_book_rounded,
                  size: 14, color: AppColors.grey400),
              const SizedBox(width: 6),
              Text(booking.subject, style: AppTextStyles.bodyMedium),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.grey400),
              const SizedBox(width: 6),
              Text(booking.slot, style: AppTextStyles.bodyMedium),
            ]),
            // Note if present
            if (booking.note != null && booking.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(booking.note!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
            // Action buttons
            if (booking.isPending || booking.isConfirmed) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(children: [
                if (isTutor && booking.isPending && onConfirm != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onConfirm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                if (isTutor && booking.isPending) const SizedBox(width: 8),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

// Coloured pill showing booking status
class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;

    switch (status) {
      case BookingStatus.pending:
        bg = AppColors.accentSurface;
        fg = AppColors.accent;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        bg = AppColors.successSurface;
        fg = AppColors.success;
        label = 'Confirmed';
        break;
      case BookingStatus.cancelled:
        bg = AppColors.errorSurface;
        fg = AppColors.error;
        label = 'Cancelled';
        break;
      case BookingStatus.completed:
        bg = AppColors.grey100;
        fg = AppColors.grey500;
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: fg)),
    );
  }
}
