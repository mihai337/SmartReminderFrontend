import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smartreminders/services/notification_service.dart';
import 'package:smartreminders/services/task_service.dart';

import '../models/task.dart';

class WiFiService {
  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;
  final TaskService _taskService;
  final NotificationService _notificationService;

  static final WiFiService _instance = WiFiService._internal();
  factory WiFiService() => _instance;
  WiFiService._internal()
      : _connectivity = Connectivity(),
        _networkInfo = NetworkInfo(),
        _taskService = TaskService(),
        _notificationService = NotificationService();

  Future<String?> getCurrentWiFiSSID() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return await _networkInfo.getWifiName();
    }
    return null;
  }

  Future<bool> isConnectedToWiFi(String ssid) async {
    final currentSSID = await getCurrentWiFiSSID();
    if (currentSSID == null) return false;
    return currentSSID.replaceAll('"', '').toLowerCase() == ssid.toLowerCase();
  }

  void monitorWiFiChanges() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) async {
      final tasks = await _taskService.taskStream.first;

      for (var task in tasks) {
        if (task.trigger is WifiTrigger) {
          final wifiTrigger = task.trigger as WifiTrigger;
          // TODO: implement onEnter and onExit logic
          final isConnected = await isConnectedToWiFi(wifiTrigger.ssid);
          if (isConnected) {
            _notificationService.showTaskNotification(task);
          }
        }
      }
    });
  }

  Future<List<String>> getKnownNetworks() async {
    final currentSSID = await getCurrentWiFiSSID();
    if (currentSSID != null) {
      return [currentSSID.replaceAll('"', '')];
    }
    return [];
  }
}
