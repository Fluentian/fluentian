import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_push_service.dart';
import 'notifications_api.dart';

class RemotePushService {
  RemotePushService._();
  static final RemotePushService instance = RemotePushService._();

  final _messaging = FirebaseMessaging.instance;
  bool _initialized = false;
  Future<void>? _initializationFuture;
  bool _registered = false;

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Local notification initialization owns the Android/iOS permission
      // prompt. Await it so Firebase cannot open a second system dialog while
      // that request is still active.
      await LocalPushService.instance.initialize();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
      FirebaseMessaging.onMessage.listen((message) async {
        final notification = message.notification;
        if (notification == null) return;
        await LocalPushService.instance.showRemoteNotification(
          title: notification.title ?? 'Fluentian',
          body: notification.body ?? '',
        );
      });
      _messaging.onTokenRefresh.listen((token) => _register(token));
      _initialized = true;
    } catch (_) {
      _initializationFuture = null;
      rethrow;
    }
  }

  Future<void> configure({required bool enabled}) async {
    await initialize();
    if (!enabled || _registered) return;
    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) await _register(token);
  }

  Future<void> _register(String token) async {
    try {
      await NotificationsApi.instance.registerDevice(
        token,
        Platform.isAndroid
            ? 'android'
            : Platform.isIOS
            ? 'ios'
            : 'other',
      );
      _registered = true;
    } catch (_) {
      _registered = false;
    }
  }
}
