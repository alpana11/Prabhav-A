import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final _apiService = ApiService();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 30),
        ),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get location with address (requires reverse geocoding setup)
  Future<Map<String, dynamic>?> getLocationWithAddress() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return null;

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
        // Address would require Google Maps API
        'address': 'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
      };
    } catch (e) {
      print('Error getting location with address: $e');
      return null;
    }
  }

  /// Update location on backend
  Future<bool> updateLocationOnBackend() async {
    try {
      final locationData = await getLocationWithAddress();
      if (locationData == null) {
        return false;
      }

      final result = await _apiService.updateLocation(
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        address: locationData['address'],
        accuracy: locationData['accuracy'],
      );

      return result['success'] ?? false;
    } catch (e) {
      print('Error updating location on backend: $e');
      return false;
    }
  }

  /// Start continuous location updates
  Stream<Position> getPositionStream({
    Duration interval = const Duration(seconds: 10),
    int distanceFilter = 10, // meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
        timeLimit: interval,
      ),
    );
  }

  /// Stop location updates (if using stream)
  void stopLocationUpdates() {
    // StreamSubs are handled by caller
  }
}
