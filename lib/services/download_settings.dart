import 'package:shared_preferences/shared_preferences.dart';

/// Persisted preference for whether bulk unit downloads should be
/// restricted to Wi-Fi. Defaults to true: the target audience is on
/// slow, expensive Ethiopian mobile data, so opting into cellular
/// downloads should be a deliberate choice, not the default.
class DownloadSettings {
  DownloadSettings._();
  static final DownloadSettings instance = DownloadSettings._();

  static const _wifiOnlyKey = 'fluentian_downloads_wifi_only';

  Future<bool> getWifiOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_wifiOnlyKey) ?? true;
  }

  Future<void> setWifiOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_wifiOnlyKey, value);
  }
}
