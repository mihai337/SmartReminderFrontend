import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import 'package:smartreminders/models/task.dart';
import 'package:smartreminders/services/api_service.dart';
import 'package:smartreminders/services/location_service.dart';

// TODO: try to use background_service.dart for location polling and task checking
class LocationTaskWatcher {
  LocationTaskWatcher()
      : _api = ApiClient(),
        _locationService = LocationService();

  final ApiClient _api;
  final LocationService _locationService;

  Timer? _timer;

  /// Start checking every 2 minutes
  void start({
    required void Function(
        Task task,
        double distanceMeters,
        bool insideRadius,
        ) onCheck,
  }) async {
    _timer?.cancel();

    final allowed = await _locationService.requestPermission();
    if (!allowed) return;

    await _tick(onCheck);

    _timer = Timer.periodic(
      const Duration(minutes: 2),
          (_) => _tick(onCheck),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _tick(
      void Function(Task, double, bool) onCheck,
      ) async {

    final position = await _locationService.getCurrentLocation();
    if (position == null) return;

    // TODO: call API only when changes are made, or cache tasks locally
    final resp = await _api.get('/api/task');
    if (resp.statusCode < 200 || resp.statusCode >= 300) return;

    final decoded = json.decode(resp.body);
    List<dynamic> list = [];

    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map && decoded['data'] is List) {
      list = decoded['data'];
    }

    final tasks = list.map((e) {
      final map = e is Map<String, dynamic>
          ? e
          : Map<String, dynamic>.from(e as Map);
      return Task.fromJson(map);
    }).toList();

    for (final task in tasks) {
      if (task.trigger is! LocationTrigger) continue;

      final trigger = task.trigger as LocationTrigger;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        trigger.latitude,
        trigger.longitude,
      );

      final insideRadius = distance <= trigger.radius;

      onCheck(task, distance, insideRadius);
    }
  }
}
