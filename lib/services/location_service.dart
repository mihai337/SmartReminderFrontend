import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    // return _firestore.collection('locations')
    //     .where('userId', isEqualTo: userId)
    //     .orderBy('createdAt', descending: true)
    //     .snapshots()
    //     .map((snapshot) =>
    //         snapshot.docs.map((doc) => SavedLocation.fromJson(doc.data())).toList());
    throw UnimplementedError();
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
