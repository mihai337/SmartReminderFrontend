import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartreminders/models/saved_location.dart';
import 'package:smartreminders/services/api_service.dart';


class LocationService {
  LocationService() : _api = ApiClient();

  final ApiClient _api;
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
    var requestBody = {
      'name': location.name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'radius': location.radius,
    };
    _api.post("/api/user/location",  requestBody);
  }

  Future<void> deleteLocation(String locationId) async {

  }

  Stream<List<SavedLocation>> getSavedLocations() async* {
    try {
      final resp = await _api.get('/api/user/location');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = json.decode(resp.body);

        if (decoded is List) {
          final locations =
              decoded.map<SavedLocation>((e) => SavedLocation.fromJson(e)).toList();
          yield locations;
        } else {
          yield <SavedLocation>[];
        }
      } else {
        throw Exception('Failed to load locations: ${resp.statusCode}');
      }
    } catch (error) {
      // This will send an error event on the stream
      throw Exception('Error fetching locations: $error');
    }
  }

  bool isInGeofence(double currentLat, double currentLng, SavedLocation location) {
    final distance = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      location.latitude,
      location.longitude,
    );
    return distance <= location.radius;
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
