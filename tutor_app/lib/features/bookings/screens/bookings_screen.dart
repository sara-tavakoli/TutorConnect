import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';

//Shows all bookings split into Upcoming and Past tabs. Tutors see confirm/cancel buttons; students only see cancel.

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late BookingProvider _bookingProvider;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _bookingProvider = BookingProvider();

    // Init with current user's uid and role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        _bookingProvider.init(auth.user!.uid, auth.user!.role);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isTutor = auth.user?.isTutor ?? false;

    return ChangeNotifierProvider.value(
      value: _bookingProvider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          title: Text(isTutor ? 'Session Requests' : 'My Bookings',
              style: AppTextStyles.headlineMedium),
          bottom: TabBar(
            controller: _tabCtrl,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey400,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: AppTextStyles.labelLarge,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              controller: _tabCtrl,
              children: [
                _BookingList(
                  bookings: provider.upcoming,
                  isTutor: isTutor,
                  emptyMessage: 'No upcoming sessions',
                  emptyIcon: Icons.calendar_today_rounded,
                  provider: provider,
                ),
                _BookingList(
                  bookings: provider.past,
                  isTutor: isTutor,
                  emptyMessage: 'No past sessions',
                  emptyIcon: Icons.history_rounded,
                  provider: provider,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool isTutor;
  final String emptyMessage;
  final IconData emptyIcon;
  final BookingProvider provider;

  const _BookingList({
    required this.bookings,
    required this.isTutor,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.xxlAll,
              ),
              child: Icon(emptyIcon, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(emptyMessage, style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text('Your sessions will appear here.',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: bookings.length,
      itemBuilder: (_, i) {
        final b = bookings[i];
        return BookingCard(
          booking: b,
          isTutor: isTutor,
          onConfirm: isTutor && b.isPending
              ? () => provider.updateStatus(b.id, BookingStatus.confirmed)
              : null,
          onCancel: b.isPending || b.isConfirmed
              ? () => _confirmCancel(context, b.id)
              : null,
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        title: Text('Cancel session?', style: AppTextStyles.titleMedium),
        content:
            Text('This cannot be undone.', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () {
              provider.updateStatus(bookingId, BookingStatus.cancelled);
              Navigator.pop(context);
            },
            child: Text('Cancel session',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
