import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:smartreminders/models/saved_location.dart';
import 'package:smartreminders/services/api_service.dart';
import 'package:smartreminders/services/notification_service.dart';
import 'package:smartreminders/services/task_service.dart';

import '../models/task.dart';


class LocationService {
  static final LocationService _instance = LocationService.internal();
  factory LocationService() => _instance;
  LocationService.internal():
        _api = ApiClient(),
        _notificationService = NotificationService(),
        _taskService = TaskService();

  final ApiClient _api;
  final TaskService _taskService;
  final NotificationService _notificationService;

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

  void monitorLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    ).listen((Position position) async {
      final tasks = await _taskService.taskStream.first;
      for(var task in tasks) {
        if (task.trigger is! LocationTrigger) continue;

        final trigger = task.trigger as LocationTrigger;

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          trigger.latitude,
          trigger.longitude,
        );

        final sendNotif = trigger.onEnter ? distance <= trigger.radius : distance >= trigger.radius;

        if (sendNotif) {
          _notificationService.showTaskNotification(task);
        }
      }
    });
  }
}
