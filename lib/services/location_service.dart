import 'package:geolocator/geolocator.dart';
import 'package:smartreminders/models/saved_location.dart';

class LocationService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<void> saveLocation(SavedLocation location) async {
    // await _firestore.collection('locations').doc(location.id).set(location.toJson());
  }

  Future<void> deleteLocation(String locationId) async {
    // await _firestore.collection('locations').doc(locationId).delete();
  }

  Stream<List<SavedLocation>> getSavedLocations(String userId) {
    // Firestore integration is currently disabled for this build.
    // Return an empty stream so the UI can handle "no locations" gracefully.
    return Stream.value(<SavedLocation>[]);
  }

  bool isInGeofence(double currentLat, double currentLng, SavedLocation location) {
    final distance = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      location.latitude,
      location.longitude,
    );
    return distance <= location.radiusMeters;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
