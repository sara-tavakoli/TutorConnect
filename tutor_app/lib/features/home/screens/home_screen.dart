import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/booking_model.dart';
import '../../../services/booking_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../tutors/screens/tutor_feed_screen.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../map/screens/map_screen.dart';
import '../../profile/screens/profile_screen.dart';

// Tab indices
// 0 = Dashboard, 1 = Browse, 2 = Map, 3 = Bookings, 4 = Profile

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _navigateTo(int index) => setState(() => _currentIndex = index);

  List<Widget> get _pages => [
    DashboardScreen(onNavigate: _navigateTo),
    const TutorFeedScreen(),
    const MapScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final user    = auth.user;
    final isTutor = user?.isTutor ?? false;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.grey100, width: 1),
          ),
          boxShadow: AppShadows.sm,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon:       Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label:      'Home',
                  selected:   _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon:       Icons.search_rounded,
                  activeIcon: Icons.search_rounded,
                  label:      'Browse',
                  selected:   _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon:       Icons.map_outlined,
                  activeIcon: Icons.map_rounded,
                  label:      'Map',
                  selected:   _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                // Bookings tab with live pending badge
                if (user != null)
                  StreamBuilder<List<BookingModel>>(
                    stream: isTutor
                        ? BookingService().getBookingsForTutor(user.uid)
                        : BookingService().getBookingsForStudent(user.uid),
                    builder: (context, snap) {
                      final bookings = snap.data ?? [];
                      final badgeCount = isTutor
                          ? bookings.where((b) => b.isPending).length
                          : bookings
                              .where((b) => b.isPending || b.isConfirmed)
                              .length;
                      return _NavItem(
                        icon:       Icons.calendar_today_outlined,
                        activeIcon: Icons.calendar_today_rounded,
                        label:      isTutor ? 'Requests' : 'Bookings',
                        selected:   _currentIndex == 3,
                        badge:      badgeCount > 0 ? badgeCount : null,
                        onTap: () => setState(() => _currentIndex = 3),
                      );
                    },
                  )
                else
                  _NavItem(
                    icon:       Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today_rounded,
                    label:      'Bookings',
                    selected:   _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                _NavItem(
                  icon:       Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label:      'Profile',
                  selected:   _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData     icon;
  final IconData     activeIcon;
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  final int?         badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primarySurface
              : Colors.transparent,
          borderRadius: AppRadius.fullAll,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: selected
                      ? AppColors.primary
                      : AppColors.grey400,
                  size: 22,
                ),
                if (badge != null)
                  Positioned(
                    top: -4, right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppRadius.fullAll,
                        border: Border.all(
                            color: AppColors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                          minWidth: 16, minHeight: 16),
                      child: Text(
                        badge! > 99 ? '99+' : '$badge',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 9,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: selected
                    ? AppColors.primary
                    : AppColors.grey400,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}