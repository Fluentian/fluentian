import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notifications_api.dart';

class LocalPushService {
  LocalPushService._();
  static final LocalPushService instance = LocalPushService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  Timer? _timer;
  final Set<String> _notifiedIds = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Request permissions for Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  void startPolling() {
    if (_timer != null) return;
    
    // Check every 15 seconds for new admin notifications
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _checkNotifications());
    _checkNotifications(); // check immediately
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkNotifications() async {
    try {
      final unread = await NotificationsApi.instance.getNotifications(isRead: false);
      for (final notification in unread) {
        if (!_notifiedIds.contains(notification.id)) {
          _notifiedIds.add(notification.id);
          await _showNotification(
            id: notification.id.hashCode,
            title: notification.title,
            body: notification.body,
          );
        }
      }
    } catch (e) {
      // Ignore errors (e.g., if not logged in or backend offline)
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
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
  }

  Future<void> showTestNotification() async {
    await initialize();
    await _showNotification(
      id: 0,
      title: 'Time to learn! 🇫🇷',
      body: 'Your daily goal is waiting for you.',
    );
  }
}
