import 'package:smartreminders/services/location_service.dart';
import 'package:smartreminders/services/wifi_service.dart';

class BackgroundManager{
  final WiFiService _wifiService;
  final LocationService _locationService;

  static final BackgroundManager _instance = BackgroundManager.internal();
  factory BackgroundManager() => _instance;
  BackgroundManager.internal() :
        _wifiService = WiFiService(),
        _locationService = LocationService()
  {
    _wifiService.monitorWiFiChanges();
    _locationService.monitorLocationChanges();
  }

}