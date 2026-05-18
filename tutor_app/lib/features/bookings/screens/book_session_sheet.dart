import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/booking_model.dart';
import '../../../models/tutor_model.dart';
import '../../../services/booking_service.dart';
import '../../auth/providers/auth_provider.dart';

//A bottom sheet that slides up when a student taps Book. They pick a subject, choose a time slot, add an optional note, then confirm.

class BookSessionSheet extends StatefulWidget {
  final TutorModel tutor;
  const BookSessionSheet({super.key, required this.tutor});

  @override
  State<BookSessionSheet> createState() => _BookSessionSheetState();
}

class _BookSessionSheetState extends State<BookSessionSheet> {
  String? _selectedSubject;
  String? _selectedSlot;
  final _noteCtrl  = TextEditingController();
  bool    _isLoading = false;
  // Use BookingService directly — no provider needed in the sheet
  final _bookingService = BookingService();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedSubject == null || _selectedSlot == null) return;
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();

      final booking = BookingModel(
        id:          '',
        studentId:   auth.user!.uid,
        studentName: auth.user!.name,
        tutorId:     widget.tutor.uid,
        tutorName:   widget.tutor.name,
        subject:     _selectedSubject!,
        slot:        _selectedSlot!,
        status:      BookingStatus.pending,
        createdAt:   DateTime.now(),
        note: _noteCtrl.text.trim().isEmpty
            ? null
            : _noteCtrl.text.trim(),
      );

      await _bookingService.createBooking(booking);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Booking request sent to ${widget.tutor.name}!',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Failed to book: ${e.toString()}',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdAll),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Book a session',
                style: AppTextStyles.headlineMedium),
            Text('with ${widget.tutor.name}',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),

            // Subject picker 
            Text('Subject', style: AppTextStyles.labelLarge),
            const SizedBox(height: 10),
            widget.tutor.subjects.isEmpty
                ? Text('No subjects listed.',
                    style: AppTextStyles.bodyMedium)
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    children: widget.tutor.subjects.map((s) {
                      final active = s == _selectedSubject;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedSubject = s),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : AppColors.grey50,
                            borderRadius: AppRadius.fullAll,
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.grey200,
                            ),
                          ),
                          child: Text(s,
                              style: AppTextStyles.labelLarge
                                  .copyWith(
                                color: active
                                    ? AppColors.white
                                    : AppColors.grey700,
                              )),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 24),

            // ── Slot picker ─────────────────────────────────────
            Text('Available slot', style: AppTextStyles.labelLarge),
            const SizedBox(height: 10),
            widget.tutor.availability.isEmpty
                ? Text('No slots available.',
                    style: AppTextStyles.bodyMedium)
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    children: widget.tutor.availability.map((slot) {
                      final active = slot == _selectedSlot;
                      final taken = widget.tutor.bookedSlots.contains(slot);
                      return GestureDetector(
                        onTap: taken
                            ? null
                            : () => setState(() => _selectedSlot = slot),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: taken
                                ? AppColors.grey100
                                : active
                                    ? AppColors.primarySurface
                                    : AppColors.grey50,
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(
                              color: taken
                                  ? AppColors.grey200
                                  : active
                                      ? AppColors.primary
                                      : AppColors.grey200,
                              width: active && !taken ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(slot,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(
                                    color: taken
                                        ? AppColors.grey400
                                        : active
                                            ? AppColors.primary
                                            : AppColors.grey700,
                                    decoration: taken
                                        ? TextDecoration.lineThrough
                                        : null,
                                  )),
                              if (taken) ...[
                                const SizedBox(width: 4),
                                Text('Booked',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                            color: AppColors.grey400)),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 24),

            // Note
            Text('Note (optional)',
                style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey900),
              decoration: InputDecoration(
                hintText: 'e.g. I need help with integration…',
                hintStyle: AppTextStyles.bodyMedium,
              ),
            ),

            const SizedBox(height: 28),

            //  Confirm button 
            AppButton(
              label: 'Confirm Booking',
              isLoading: _isLoading,
              onPressed:
                  (_selectedSubject != null && _selectedSlot != null)
                      ? _confirm
                      : null,
            ),

            // Helper text when nothing selected yet
            if (_selectedSubject == null || _selectedSlot == null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Select a subject and slot to continue',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
