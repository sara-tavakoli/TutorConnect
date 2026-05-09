import 'package:geolocator/geolocator.dart';

//Gets the device's current GPS position and calculates distance between two coordinates.

/// Handles GPS permission, current position, and distance calculation.
class LocationService {

  // Request permission and get current position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Returns distance in km between two lat/lng points
  double distanceInKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    final metres = Geolocator.distanceBetween(
        fromLat, fromLng, toLat, toLng);
    return metres / 1000;
  }

  // Formats distance nicely — "0.3 km" or "1.2 km"
  String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)}m away';
    return '${km.toStringAsFixed(1)}km away';
  }
}