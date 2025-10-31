import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WiFiService {
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

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
    // Note: Getting list of known networks is not directly supported on all platforms
    // This is a placeholder that returns the current network if connected
    final currentSSID = await getCurrentWiFiSSID();
    if (currentSSID != null) {
      return [currentSSID.replaceAll('"', '')];
    }
    return [];
  }
}
