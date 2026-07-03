import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'in_app_notification_service.dart';
import 'notifications_api.dart';

class LocalPushService {
  LocalPushService._();
  static final LocalPushService instance = LocalPushService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final Set<String> _notifiedIds = {};

  Timer? _pollTimer;
  Timer? _reminderTimer;
  bool _initialized = false;
  bool _notificationsEnabled = true;
  bool _learningReminderEnabled = true;
  String _reminderTime = '08:00';
  String? _lastReminderKey;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> configure({
    required bool notificationsEnabled,
    required bool learningReminderEnabled,
    required String reminderTime,
  }) async {
    await initialize();

    final reminderChanged = _reminderTime != reminderTime;
    _notificationsEnabled = notificationsEnabled;
    _learningReminderEnabled = learningReminderEnabled;
    _reminderTime = reminderTime;
    if (reminderChanged) _lastReminderKey = null;

    if (_notificationsEnabled) {
      startPolling();
    } else {
      stopPolling();
    }

    if (_notificationsEnabled && _learningReminderEnabled) {
      _startReminderWatcher();
    } else {
      _stopReminderWatcher();
    }
  }

  void startPolling() {
    if (!_notificationsEnabled || _pollTimer != null) return;
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkNotifications(),
    );
    _checkNotifications();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _stopReminderWatcher();
  }

  void _startReminderWatcher() {
    if (_reminderTimer != null) return;
    _reminderTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkDailyReminder(),
    );
    _checkDailyReminder();
  }

  void _stopReminderWatcher() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  Future<void> _checkNotifications() async {
    if (!_notificationsEnabled) return;
    try {
      final unread = await NotificationsApi.instance.getNotifications(
        isRead: false,
      );
      for (final notification in unread) {
        if (!_notifiedIds.contains(notification.id)) {
          _notifiedIds.add(notification.id);
          await _showNotification(
            id: notification.id.hashCode,
            title: notification.title,
            body: notification.body,
            persistInApp: false,
          );
        }
      }
    } catch (_) {
      // Ignore errors when logged out, offline, or the backend is unavailable.
    }
  }

  Future<void> _checkDailyReminder() async {
    if (!_notificationsEnabled || !_learningReminderEnabled) return;

    final parts = _reminderTime.split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;
    if (hour == null || minute == null) return;

    final now = DateTime.now();
    if (now.hour != hour || now.minute != minute) return;

    final key =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $_reminderTime';
    if (_lastReminderKey == key) return;
    _lastReminderKey = key;

    await _showNotification(
      id: 1001,
      title: 'Daily practice reminder',
      body: 'A short French session keeps your streak moving.',
      inAppId: 'daily-reminder-$key',
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? inAppId,
    bool persistInApp = true,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fluentian_channel',
      'Fluentian Notifications',
      channelDescription: 'Important updates and learning reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
    if (!persistInApp) return;
    await InAppNotificationService.instance.addNotification(
      id: inAppId ?? 'local-$id-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
    );
  }

  Future<void> showTestNotification() async {
    await initialize();
    if (!_notificationsEnabled) {
      throw StateError('Notifications are disabled in settings.');
    }
    await _showNotification(
      id: 0,
      title: 'Time to learn!',
      body: 'Your daily goal is waiting for you.',
      inAppId: 'test-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
