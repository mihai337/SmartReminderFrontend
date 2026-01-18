import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WiFiService {
  final Connectivity _connectivity;
  final NetworkInfo _networkInfo;

  static final WiFiService _instance = WiFiService._internal();
  factory WiFiService() => _instance;
  WiFiService._internal()
      : _connectivity = Connectivity(),
        _networkInfo = NetworkInfo();

  Future<String?> getCurrentWiFiSSID() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return await _networkInfo.getWifiName();
    }
    return null;
  }

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<bool> isConnectedToWiFi(String ssid) async {
    final currentSSID = await getCurrentWiFiSSID();
    if (currentSSID == null) return false;
    return currentSSID.replaceAll('"', '').toLowerCase() == ssid.toLowerCase();
  }

  Future<List<String>> getKnownNetworks() async {
    final currentSSID = await getCurrentWiFiSSID();
    if (currentSSID != null) {
      return [currentSSID.replaceAll('"', '')];
    }
    return [];
  }
}
