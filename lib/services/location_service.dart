import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smartreminders/models/saved_location.dart';
import 'package:smartreminders/services/api_service.dart';
import 'package:smartreminders/services/task_service.dart';

class LocationService {
  static final LocationService _instance = LocationService.internal();
  factory LocationService() => _instance;
  LocationService.internal():
        _api = ApiClient(),
        _taskService = TaskService();

  final ApiClient _api;
  final TaskService _taskService;

  static Future<bool> requestPermission() async {
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

  //TODO: Implement deleteLocation
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
      throw Exception('Error fetching locations: $error');
    }
  }

  static const _control = MethodChannel('location_control');
  static const _stream = EventChannel('location_stream');

  Stream<Map<String, dynamic>>? _locationStream;

  Stream<Map<String, dynamic>> get stream {
    _locationStream ??= _stream
        .receiveBroadcastStream()
        .map((e) => Map<String, dynamic>.from(e));
    return _locationStream!;
  }

  Future<void> start()async {
    await _control.invokeMethod<String>('startService')
        .then((result) => print('Location service started: $result'))
        .catchError((error) => print('Error starting location service: $error'));
}

  Future<void> stop() => _control.invokeMethod('stopService');

  void monitorLocationChanges() async {
    await start();
    _taskService.taskStream.listen((tasks) async {
      // Convert each Task to Map
      final serialized = tasks.map((t) => t.toJson()).toList();

      await _control.invokeMethod<bool>('sendTasks', {'tasks': serialized});
    });
  }
}
