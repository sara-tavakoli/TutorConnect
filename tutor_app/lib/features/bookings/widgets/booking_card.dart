import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool         isTutor;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.isTutor,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow:    AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status accent bar on the left edge
              Container(
                width: 4,
                color: _statusColor(booking.status),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: name + status badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isTutor
                                  ? booking.studentName
                                  : booking.tutorName,
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: booking.status),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Subject + slot row
                      Row(children: [
                        const Icon(Icons.menu_book_rounded,
                            size: 13, color: AppColors.grey400),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(booking.subject,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.grey400),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(booking.slot,
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),

                      // Booking date
                      const SizedBox(height: 4),
                      Text(
                        'Booked ${DateFormat.MMMd().format(booking.createdAt)}',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),

                      // Session note
                      if (booking.note != null &&
                          booking.note!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color:        AppColors.grey50,
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.notes_rounded,
                                  size: 13, color: AppColors.grey400),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  booking.note!,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Action buttons
                      if (_hasActions) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.grey100),
                        const SizedBox(height: 12),
                        _ActionRow(
                          booking:    booking,
                          isTutor:    isTutor,
                          onConfirm:  onConfirm,
                          onComplete: onComplete,
                          onCancel:   onCancel,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasActions =>
      (isTutor && booking.isPending && onConfirm  != null) ||
      (isTutor && booking.isConfirmed && onComplete != null) ||
      ((booking.isPending || booking.isConfirmed) && onCancel != null);

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:   return AppColors.accent;
      case BookingStatus.confirmed: return AppColors.primary;
      case BookingStatus.completed: return AppColors.success;
      case BookingStatus.cancelled: return AppColors.grey300;
    }
  }
}

// ── Action row ─────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final BookingModel  booking;
  final bool          isTutor;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _ActionRow({
    required this.booking,
    required this.isTutor,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Confirm (tutor, pending only)
        if (isTutor && booking.isPending && onConfirm != null) ...[
          Expanded(child: _ActionButton(
            label: 'Confirm',
            color: AppColors.success,
            icon:  Icons.check_rounded,
            onTap: onConfirm!,
          )),
          const SizedBox(width: 8),
        ],

        // Mark Complete (tutor, confirmed only)
        if (isTutor && booking.isConfirmed && onComplete != null) ...[
          Expanded(child: _ActionButton(
            label: 'Mark Done',
            color: AppColors.success,
            icon:  Icons.task_alt_rounded,
            onTap: onComplete!,
          )),
          const SizedBox(width: 8),
        ],

        // Cancel (either role, if pending or confirmed)
        if ((booking.isPending || booking.isConfirmed) && onCancel != null)
          Expanded(child: _ActionButton(
            label:     'Cancel',
            color:     AppColors.error,
            icon:      Icons.close_rounded,
            outlined:  true,
            onTap:     onCancel!,
          )),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String       label;
  final Color        color;
  final IconData     icon;
  final bool         outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side:            BorderSide(color: color),
          minimumSize:     const Size(0, 36),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        icon:  Icon(icon, size: 14),
        label: Text(label, style: AppTextStyles.labelSmall.copyWith(
            color: color, letterSpacing: 0)),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        elevation:       0,
        minimumSize:     const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      icon:  Icon(icon, size: 14),
      label: Text(label, style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white, letterSpacing: 0)),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      BookingStatus.pending   => (AppColors.accentSurface,  AppColors.accent,  'Pending'),
      BookingStatus.confirmed => (AppColors.primarySurface, AppColors.primary, 'Confirmed'),
      BookingStatus.cancelled => (AppColors.errorSurface,   AppColors.error,   'Cancelled'),
      BookingStatus.completed => (AppColors.successSurface, AppColors.success, 'Completed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(label,
          style: AppTextStyles.labelSmall.copyWith(color: fg)),
    );
  }
}
