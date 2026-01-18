import 'package:smartreminders/services/background_service.dart';
import 'package:smartreminders/services/task_service.dart';
import 'package:workmanager/workmanager.dart';

import '../models/observer.dart';
import '../models/task.dart';

class BackgroundManager implements TaskObserver{
  final TaskService _taskService;
  static const String _updateLocationTaskKey = 'update_location_by_distance_filter';

  static final BackgroundManager _instance = BackgroundManager.internal();
  factory BackgroundManager() => _instance;
  BackgroundManager.internal() : _taskService = TaskService() {
    _taskService.registerObserver(this);
  }

  bool _isUpdatingLocationHelper = false;

  @override
  void update() {
    _locationHelper();
  }

  Future<void> _locationHelper() async {
    if(_isUpdatingLocationHelper) return;
    _isUpdatingLocationHelper = true;

    bool isScheduled = await Workmanager().isScheduledByUniqueName(_updateLocationTaskKey);
    bool isLocationTaskPresent = await _taskService.taskStream.any((tasks) => tasks.any((task) => task.trigger is LocationTrigger));

    if(isLocationTaskPresent){
      if(!isScheduled){
        await BackgroundService.registerPeriodicTask(_updateLocationTaskKey);
      }
    } else {
      if(isScheduled){
        await BackgroundService.cancelTask(_updateLocationTaskKey);
      }
    }
    _isUpdatingLocationHelper = false;
  }

}