import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../features/tutors/providers/tutor_provider.dart';
import '../../../features/tutors/screens/tutor_detail_screen.dart';
import '../../../models/tutor_model.dart';
import '../../../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  TutorModel? _selectedTutor;
  final LocationService _locationService = LocationService();

  // Default to Sydney if no location
  static const _defaultTarget = LatLng(-33.8688, 151.2093);

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (mounted) {
      setState(() => _userPosition = position);
      if (position != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14,
          ),
        );
      }
    }
  }

  Set<Marker> _buildMarkers(List<TutorModel> tutors) {
    return tutors
        .where((t) => t.hasLocation)
        .map((t) => Marker(
              markerId: MarkerId(t.uid),
              position: LatLng(t.latitude!, t.longitude!),
              infoWindow: InfoWindow(title: t.name),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              onTap: () => setState(() => _selectedTutor = t),
            ))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TutorProvider(),
      child: Builder(builder: (context) {
        final provider = context.watch<TutorProvider>();
        final tutors = provider.allTutors;
        final markers = _buildMarkers(tutors);

        return Scaffold(
          body: Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _userPosition != null
                      ? LatLng(
                          _userPosition!.latitude, _userPosition!.longitude)
                      : _defaultTarget,
                  zoom: 14,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (ctrl) {
                  _mapController = ctrl;
                  if (_userPosition != null) {
                    ctrl.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                            _userPosition!.latitude, _userPosition!.longitude),
                        14,
                      ),
                    );
                  }
                },
                onTap: (_) => setState(() => _selectedTutor = null),
              ),

              // Top bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.fullAll,
                          boxShadow: AppShadows.md,
                        ),
                        child: Row(children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${tutors.where((t) => t.hasLocation).length} tutors on campus',
                            style: AppTextStyles.labelLarge,
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // My location button
                    GestureDetector(
                      onTap: _loadUserLocation,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadius.fullAll,
                          boxShadow: AppShadows.md,
                        ),
                        child: const Icon(Icons.my_location_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                  ]),
                ),
              ),

              // Selected tutor card
              if (_selectedTutor != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: _TutorMapCard(
                    tutor: _selectedTutor!,
                    userPosition: _userPosition,
                    onClose: () => setState(() => _selectedTutor = null),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// Tutor info card that appears when pin is tapped
class _TutorMapCard extends StatelessWidget {
  final TutorModel tutor;
  final Position? userPosition;
  final VoidCallback onClose;

  const _TutorMapCard({
    required this.tutor,
    required this.userPosition,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    String? distanceText;

    if (userPosition != null && tutor.hasLocation) {
      final km = locationService.distanceInKm(
        fromLat: userPosition!.latitude,
        fromLng: userPosition!.longitude,
        toLat: tutor.latitude!,
        toLng: tutor.longitude!,
      );
      distanceText = locationService.formatDistance(km);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow: AppShadows.lg,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lgAll,
                  color: AppColors.primarySurface,
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.lgAll,
                  child: tutor.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: tutor.photoUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person_rounded,
                          color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tutor.name, style: AppTextStyles.titleMedium),
                    if (tutor.university != null) ...[
                      const SizedBox(height: 2),
                      Text(tutor.university!, style: AppTextStyles.bodySmall),
                    ],
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(tutor.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall),
                      const SizedBox(width: 10),
                      Text(
                        '\$${tutor.hourlyRate.toStringAsFixed(0)}/hr',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.primary),
                      ),
                      if (distanceText != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.grey400),
                        const SizedBox(width: 2),
                        Text(distanceText, style: AppTextStyles.bodySmall),
                      ],
                    ]),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: tutor.subjects
                          .take(2)
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: AppRadius.fullAll,
                                ),
                                child: Text(s,
                                    style: AppTextStyles.labelSmall
                                        .copyWith(color: AppColors.primary)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              // Close button
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded,
                    color: AppColors.grey400, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'View Full Profile',
            height: 44,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TutorDetailScreen(tutor: tutor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
