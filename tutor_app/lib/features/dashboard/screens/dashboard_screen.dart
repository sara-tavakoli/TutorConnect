import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../models/booking_model.dart';
import '../../../models/tutor_model.dart';
import '../../../services/booking_service.dart';
import '../../../services/tutor_service.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final user    = auth.user;
    final isTutor = user?.isTutor ?? false;

    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<BookingModel>>(
        stream: isTutor
            ? BookingService().getBookingsForTutor(user.uid)
            : BookingService().getBookingsForStudent(user.uid),
        builder: (context, snap) {
          final bookings = snap.data ?? [];
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  name:     user.name,
                  isTutor:  isTutor,
                  bookings: bookings,
                  greeting: _greeting,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isTutor
                      ? _TutorContent(
                          uid:        user.uid,
                          bookings:   bookings,
                          onNavigate: onNavigate,
                        )
                      : _StudentContent(
                          bookings:   bookings,
                          onNavigate: onNavigate,
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String             name;
  final bool               isTutor;
  final List<BookingModel> bookings;
  final String             greeting;

  const _Header({
    required this.name,
    required this.isTutor,
    required this.bookings,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final pending = bookings.where((b) => b.isPending).length;

    return Container(
      padding: EdgeInsets.only(
        top:    MediaQuery.of(context).padding.top + 20,
        left:   24,
        right:  24,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name.split(' ').first,
                      style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color:        Colors.white.withValues(alpha: 0.18),
                  borderRadius: AppRadius.fullAll,
                  border:       Border.all(
                      color: Colors.white.withValues(alpha: 0.35), width: 2),
                ),
                child: Icon(
                  isTutor
                      ? Icons.co_present_rounded
                      : Icons.menu_book_rounded,
                  color: Colors.white, size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:        Colors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isTutor
                      ? (pending > 0
                          ? Icons.notifications_active_rounded
                          : Icons.check_circle_outline_rounded)
                      : Icons.lightbulb_outline_rounded,
                  color: Colors.white, size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  isTutor
                      ? (pending > 0
                          ? '$pending pending request${pending > 1 ? 's' : ''}'
                          : 'All caught up!')
                      : 'Every session gets you closer',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student content ───────────────────────────────────────────────────────────

class _StudentContent extends StatelessWidget {
  final List<BookingModel> bookings;
  final void Function(int) onNavigate;

  const _StudentContent({
    required this.bookings,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming     = bookings.where((b) => b.isPending || b.isConfirmed).length;
    final completed    = bookings.where((b) => b.isCompleted).length;
    final uniqueTutors = bookings.map((b) => b.tutorId).toSet().length;

    final recent = [...bookings]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        _StatsRow(items: [
          _StatData('Upcoming',   '$upcoming',     Icons.calendar_today_rounded,  AppColors.primary),
          _StatData('Completed',  '$completed',    Icons.check_circle_rounded,    AppColors.success),
          _StatData('Tutors Met', '$uniqueTutors', Icons.people_alt_rounded,      AppColors.accent),
        ]),

        const SizedBox(height: 24),

        Text('Quick Actions', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _QuickAction(
              icon:  Icons.search_rounded,
              label: 'Find Tutors',
              color: AppColors.primary,
              onTap: () => onNavigate(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAction(
              icon:  Icons.calendar_month_rounded,
              label: 'My Sessions',
              color: AppColors.success,
              onTap: () => onNavigate(3),
            ),
          ),
        ]),

        const SizedBox(height: 28),

        _SectionHeader(
          title:    'Recent Activity',
          onViewAll: bookings.isNotEmpty ? () => onNavigate(3) : null,
        ),
        const SizedBox(height: 12),

        if (recent.isEmpty)
          _EmptyActivity(
            message:     'No sessions yet.\nFind a tutor and book your first session!',
            actionLabel: 'Browse Tutors',
            onAction:    () => onNavigate(1),
          )
        else
          ...recent.take(3).map(
            (b) => _RecentTile(booking: b, showTutor: true),
          ),
      ],
    );
  }
}

// ── Tutor content ─────────────────────────────────────────────────────────────

class _TutorContent extends StatelessWidget {
  final String             uid;
  final List<BookingModel> bookings;
  final void Function(int) onNavigate;

  const _TutorContent({
    required this.uid,
    required this.bookings,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final pending       = bookings.where((b) => b.isPending).length;
    final completed     = bookings.where((b) => b.isCompleted).length;
    final uniqueStudents = bookings.map((b) => b.studentId).toSet().length;

    final recent = [...bookings]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        _StatsRow(items: [
          _StatData('Pending',   '$pending',        Icons.hourglass_top_rounded,   AppColors.warning),
          _StatData('Completed', '$completed',      Icons.check_circle_rounded,    AppColors.success),
          _StatData('Students',  '$uniqueStudents', Icons.people_alt_rounded,      AppColors.primary),
        ]),

        const SizedBox(height: 20),

        FutureBuilder<TutorModel?>(
          future: TutorService().getTutorById(uid),
          builder: (context, snap) {
            if (!snap.hasData || snap.data == null) return const SizedBox();
            final tutor = snap.data!;
            return _EarningsCard(
              earnings:          completed * tutor.hourlyRate,
              completedSessions: completed,
              hourlyRate:        tutor.hourlyRate,
              rating:            tutor.rating,
              reviewCount:       tutor.reviewCount,
            );
          },
        ),

        const SizedBox(height: 24),

        Text('Quick Actions', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _QuickAction(
              icon:  Icons.edit_rounded,
              label: 'Edit Profile',
              color: AppColors.primary,
              onTap: () => onNavigate(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAction(
              icon:  Icons.calendar_month_rounded,
              label: 'View Requests',
              color: pending > 0 ? AppColors.warning : AppColors.success,
              onTap: () => onNavigate(3),
            ),
          ),
        ]),

        const SizedBox(height: 28),

        _SectionHeader(
          title:    'Recent Requests',
          onViewAll: bookings.isNotEmpty ? () => onNavigate(3) : null,
        ),
        const SizedBox(height: 12),

        if (recent.isEmpty)
          _EmptyActivity(
            message:     'No requests yet.\nComplete your profile to attract students!',
            actionLabel: 'Edit Profile',
            onAction:    () => onNavigate(4),
          )
        else
          ...recent.take(3).map(
            (b) => _RecentTile(booking: b, showTutor: false),
          ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _StatData {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _StatsRow extends StatelessWidget {
  final List<_StatData> items;
  const _StatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow:    AppShadows.sm,
      ),
      child: Row(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Container(width: 1, height: 44, color: AppColors.grey100);
          }
          return Expanded(child: _StatTile(data: items[i ~/ 2]));
        }),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color:        data.color.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(height: 8),
          Text(data.value,
              style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 20, color: AppColors.grey900)),
          const SizedBox(height: 2),
          Text(data.label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:        color.withValues(alpha: 0.08),
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        onTap:        onTap,
        borderRadius: AppRadius.lgAll,
        splashColor:  color.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.14),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTextStyles.labelLarge.copyWith(
                      color: color, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final double earnings;
  final int    completedSessions;
  final double hourlyRate;
  final double rating;
  final int    reviewCount;

  const _EarningsCard({
    required this.earnings,
    required this.completedSessions,
    required this.hourlyRate,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [Color(0xFF1A3A6B), AppColors.primary],
        ),
        borderRadius: AppRadius.xlAll,
        boxShadow:    AppShadows.primary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Earnings',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${earnings.toStringAsFixed(0)}',
                  style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedSessions completed × \$${hourlyRate.toStringAsFixed(0)}/hr',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:        Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text(rating.toStringAsFixed(1),
                      style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final BookingModel booking;
  final bool         showTutor;

  const _RecentTile({required this.booking, required this.showTutor});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final person      = showTutor ? booking.tutorName : booking.studentName;

    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: AppRadius.lgAll,
        boxShadow:    AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
                color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${booking.subject} · ${booking.slot}',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color:        statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.fullAll,
            ),
            child: Text(
              _statusLabel(booking.status),
              style: AppTextStyles.labelSmall.copyWith(
                  color: statusColor, letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:   return AppColors.warning;
      case BookingStatus.confirmed: return AppColors.primary;
      case BookingStatus.completed: return AppColors.success;
      case BookingStatus.cancelled: return AppColors.error;
    }
  }

  String _statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:   return 'Pending';
      case BookingStatus.confirmed: return 'Confirmed';
      case BookingStatus.completed: return 'Done';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String       title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View all',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  final String       message;
  final String       actionLabel;
  final VoidCallback onAction;

  const _EmptyActivity({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: AppRadius.lgAll,
        boxShadow:    AppShadows.sm,
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 32, color: AppColors.grey300),
          const SizedBox(height: 12),
          Text(message,
              style:     AppTextStyles.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
