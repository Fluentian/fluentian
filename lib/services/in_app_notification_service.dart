import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

class InAppNotificationService {
  InAppNotificationService._();
  static final InAppNotificationService instance = InAppNotificationService._();

  static const _storageKey = 'fluentian_in_app_notifications';
  static const _maxItems = 80;

  Future<List<NotificationModel>> getNotifications({bool? isRead}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_storageKey) ?? [];
    final notifications =
        rawItems
            .map(_decode)
            .whereType<NotificationModel>()
            .where(
              (notification) => isRead == null || notification.isRead == isRead,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Future<int> getUnreadCount() async {
    final unread = await getNotifications(isRead: false);
    return unread.length;
  }

  Future<void> addNotification({
    required String id,
    required String title,
    required String body,
    DateTime? createdAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = (prefs.getStringList(_storageKey) ?? [])
        .map(_decode)
        .whereType<NotificationModel>()
        .where((notification) => notification.id != id)
        .toList();
    final notification = NotificationModel(
      id: id,
      title: title,
      body: body,
      isRead: false,
      createdAt: createdAt ?? DateTime.now(),
    );
    final items = [notification, ...existing]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await prefs.setStringList(
      _storageKey,
      items.take(_maxItems).map(_encode).toList(),
    );
  }

  Future<void> markRead(String notificationId) async {
    await _update((notification) {
      if (notification.id != notificationId || notification.isRead) {
        return notification;
      }
      return notification.copyWith(isRead: true);
    });
  }

  Future<void> markAllRead() async {
    await _update((notification) => notification.copyWith(isRead: true));
  }

  Future<void> _update(
    NotificationModel Function(NotificationModel notification) transform,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final items =
        (prefs.getStringList(_storageKey) ?? [])
            .map(_decode)
            .whereType<NotificationModel>()
            .map(transform)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await prefs.setStringList(_storageKey, items.map(_encode).toList());
  }

  String _encode(NotificationModel notification) {
    return jsonEncode({
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'is_read': notification.isRead,
      'created_at': notification.createdAt.toIso8601String(),
    });
  }

  NotificationModel? _decode(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      return NotificationModel.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }
}
