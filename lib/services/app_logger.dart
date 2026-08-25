import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static const _storageKey = 'fluentian_debug_logs';
  static const _maxEntries = 250;
  static const _uploadOptInKey = 'fluentian_log_upload_opt_in';

  Future<bool> get uploadOptIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_uploadOptInKey) ?? false;
  }

  Future<void> setUploadOptIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_uploadOptInKey, value);
  }

  Future<bool> upload() async {
    if (!await uploadOptIn) return false;
    final text = await exportText();
    if (text.isEmpty) return true;
    try {
      await ApiClient.instance.post('/telemetry/logs', {'payload': text});
      await clear();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> info(String message) => _write('INFO', message);
  Future<void> warning(String message) => _write('WARN', message);
  Future<void> error(String message, [Object? error]) =>
      _write('ERROR', error == null ? message : '$message: $error');

  Future<List<String>> entries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_storageKey) ?? const [];
  }

  Future<String> exportText() async {
    final logs = await entries();
    return logs.join('\n');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _write(String level, String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final entry = '$timestamp [$level] $message';
    if (kDebugMode) debugPrint(entry);

    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList(_storageKey) ?? <String>[];
      logs.add(entry);
      if (logs.length > _maxEntries) {
        logs.removeRange(0, logs.length - _maxEntries);
      }
      await prefs.setStringList(_storageKey, logs);
    } catch (e) {
      if (kDebugMode) debugPrint('Could not persist app log: $e');
    }
  }
}
