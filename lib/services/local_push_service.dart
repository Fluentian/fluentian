import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:shared_preferences/shared_preferences.dart';
import 'in_app_notification_service.dart';
import 'notifications_api.dart';

class LocalPushService {
  LocalPushService._();
  static final LocalPushService instance = LocalPushService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final Set<String> _notifiedIds = {};

  Timer? _pollTimer;
  bool _initialized = false;
  Future<void>? _initializationFuture;
  bool _notificationsEnabled = true;
  bool _learningReminderEnabled = true;
  String _reminderTime = '08:00';
  static const _dailyReminderId = 1001;
  String? _configurationKey;

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);

      tz_data.initializeTimeZones();
      try {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimezone));
      } catch (_) {
        // tz.local remains a valid fallback; scheduling still succeeds.
      }

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      _initialized = true;
    } catch (_) {
      // Permit a later retry if initialization or the system permission dialog
      // could not complete.
      _initializationFuture = null;
      rethrow;
    }
  }

  Future<void> configure({
    required bool notificationsEnabled,
    required bool learningReminderEnabled,
    required String reminderTime,
  }) async {
    await initialize();

    final configurationKey =
        '$notificationsEnabled|$learningReminderEnabled|$reminderTime';
    if (_configurationKey == configurationKey) return;
    _configurationKey = configurationKey;

    _notificationsEnabled = notificationsEnabled;
    _learningReminderEnabled = learningReminderEnabled;
    _reminderTime = reminderTime;

    if (_notificationsEnabled) {
      startPolling();
    } else {
      stopPolling();
    }

    if (_notificationsEnabled && _learningReminderEnabled) {
      await _scheduleDailyReminder();
    } else {
      await _plugin.cancel(_dailyReminderId);
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
    _plugin.cancel(_dailyReminderId);
  }

  Future<void> _loadNotifiedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('fluentian_notified_ids') ?? [];
      _notifiedIds.addAll(list);
    } catch (_) {}
  }

  Future<void> _saveNotifiedId(String id) async {
    _notifiedIds.add(id);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('fluentian_notified_ids', _notifiedIds.toList());
    } catch (_) {}
  }

  Future<void> _checkNotifications() async {
    if (!_notificationsEnabled) return;
    try {
      if (_notifiedIds.isEmpty) {
        await _loadNotifiedIds();
      }
      final unread = await NotificationsApi.instance.getNotifications(
        isRead: false,
      );
      for (final notification in unread) {
        if (!_notifiedIds.contains(notification.id)) {
          await _saveNotifiedId(notification.id);
          try {
            await NotificationsApi.instance.markRead(notification.id);
          } catch (_) {}
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

  Future<void> _scheduleDailyReminder() async {
    final parts = _reminderTime.split(':');
    final hour = int.tryParse(parts.first);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;
    if (hour == null || minute == null) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.cancel(_dailyReminderId);
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Daily practice reminder',
      'A short French session keeps your streak moving.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fluentian_reminders',
          'Learning reminders',
          channelDescription: 'Your scheduled Fluentian learning reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
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

  Future<void> showRemoteNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    await _showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: title,
      body: body,
      persistInApp: false,
    );
  }
}
