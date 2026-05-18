import 'package:flutter_test/flutter_test.dart';
import 'package:tutorconnect/services/location_service.dart';

void main() {
  final service = LocationService();

  group('LocationService.distanceInKm', () {
    test('same point returns 0', () {
      final d = service.distanceInKm(
          fromLat: -33.8688, fromLng: 151.2093,
          toLat: -33.8688, toLng: 151.2093);
      expect(d, closeTo(0.0, 0.001));
    });

    test('Sydney to Melbourne is roughly 713 km', () {
      final d = service.distanceInKm(
          fromLat: -33.8688, fromLng: 151.2093,
          toLat: -37.8136, toLng: 144.9631);
      expect(d, closeTo(713.0, 20.0));
    });

    test('returns positive value for arbitrary points', () {
      final d = service.distanceInKm(
          fromLat: 0, fromLng: 0, toLat: 1, toLng: 1);
      expect(d, greaterThan(0));
    });
  });

  group('LocationService.formatDistance', () {
    test('sub-kilometre distances shown in metres', () {
      expect(service.formatDistance(0.3), '300m away');
    });

    test('exact 1 km shows 1.0km', () {
      expect(service.formatDistance(1.0), '1.0km away');
    });

    test('distances >= 1 km shown with one decimal place', () {
      expect(service.formatDistance(5.678), '5.7km away');
    });

    test('very small distance rounds to 0m', () {
      expect(service.formatDistance(0.0001), '0m away');
    });
  });
}
