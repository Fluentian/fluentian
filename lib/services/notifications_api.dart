import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationsApi {
  NotificationsApi._();
  static final NotificationsApi instance = NotificationsApi._();

  final _client = ApiClient.instance;

  Future<List<NotificationModel>> getNotifications({bool? isRead}) async {
    final params = <String>['size=100'];
    if (isRead != null) params.add('is_read=$isRead');
    final items = await _client.getList('/notifications/?${params.join('&')}');
    return items
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final unread = await getNotifications(isRead: false);
    return unread.length;
  }

  Future<void> markRead(String notificationId) async {
    await _client.patch('/notifications/$notificationId/read', {});
  }

  Future<void> markAllRead() async {
    await _client.patch('/notifications/read-all', {});
  }
}
