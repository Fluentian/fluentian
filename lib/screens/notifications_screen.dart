import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme.dart';
import '../models/notification_model.dart';
import '../services/api_client.dart';
import '../services/in_app_notification_service.dart';
import '../services/notifications_api.dart';

enum _NotificationSource { backend, local }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = NotificationsApi.instance;
  final _localApi = InAppNotificationService.instance;
  late Future<_InboxData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadInbox();
  }

  Future<_InboxData> _loadInbox() async {
    Object? backendError;
    var backendItems = <NotificationModel>[];
    try {
      backendItems = await _api.getNotifications();
    } catch (e) {
      backendError = e;
    }

    final localItems = await _localApi.getNotifications();
    final items = [
      ...backendItems.map(
        (notification) => _InboxNotification(
          notification: notification,
          source: _NotificationSource.backend,
        ),
      ),
      ...localItems.map(
        (notification) => _InboxNotification(
          notification: notification,
          source: _NotificationSource.local,
        ),
      ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _InboxData(items: items, backendError: backendError);
  }

  void _reload() {
    setState(() {
      _future = _loadInbox();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadInbox();
    });
    await _future;
  }

  Future<void> _markRead(_InboxNotification item) async {
    if (item.isRead) return;
    if (item.source == _NotificationSource.backend) {
      await _api.markRead(item.id);
    } else {
      await _localApi.markRead(item.id);
    }
    _reload();
  }

  Future<void> _markAllRead() async {
    await Future.wait([
      _api.markAllRead().catchError((_) {}),
      _localApi.markAllRead(),
    ]);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          FutureBuilder<_InboxData>(
            future: _future,
            builder: (context, snapshot) {
              final unread = snapshot.data?.unreadCount ?? 0;
              if (unread == 0) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: _markAllRead,
                icon: const Icon(Iconsax.tick_circle, size: 16),
                label: const Text('Mark all read'),
                style: TextButton.styleFrom(
                  foregroundColor: FluentianColors.primary,
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<_InboxData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Iconsax.cloud_cross,
              title: 'Could not load inbox',
              message: 'Pull to retry or check your connection.',
              actionLabel: 'Retry',
              onAction: _reload,
            );
          }

          final data = snapshot.data ?? const _InboxData(items: []);
          if (data.items.isEmpty) {
            final message = data.backendErrorMessage ??
                'Learning reminders, streak nudges, and Fluentian updates will appear here.';
            return _MessageState(
              icon: Iconsax.notification,
              title: 'No notifications yet',
              message: message,
              actionLabel: data.backendError == null ? null : 'Retry',
              onAction: data.backendError == null ? null : _reload,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _InboxHeader(data: data),
                if (data.backendError != null) ...[
                  const SizedBox(height: 12),
                  _SyncWarning(message: data.backendErrorMessage),
                ],
                const SizedBox(height: 14),
                ...data.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _NotificationTile(
                      item: item,
                      onTap: () => _markRead(item),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InboxData {
  final List<_InboxNotification> items;
  final Object? backendError;

  const _InboxData({required this.items, this.backendError});

  int get unreadCount => items.where((item) => !item.isRead).length;
  int get localCount =>
      items.where((item) => item.source == _NotificationSource.local).length;

  String? get backendErrorMessage {
    final error = backendError;
    if (error == null) return null;
    if (error is ApiException) return error.userMessage;
    return 'Backend notifications could not sync right now.';
  }
}

class _InboxNotification {
  final NotificationModel notification;
  final _NotificationSource source;

  const _InboxNotification({
    required this.notification,
    required this.source,
  });

  String get id => notification.id;
  String get title => notification.title;
  String get body => notification.body;
  bool get isRead => notification.isRead;
  DateTime get createdAt => notification.createdAt;
  bool get isLocal => source == _NotificationSource.local;
}

class _InboxHeader extends StatelessWidget {
  final _InboxData data;

  const _InboxHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: FluentianColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [FluentianShadows.card],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Iconsax.notification_status,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.unreadCount == 0
                      ? 'You are all caught up'
                      : '${data.unreadCount} unread update${data.unreadCount == 1 ? '' : 's'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${data.items.length} total - ${data.localCount} from this app',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncWarning extends StatelessWidget {
  final String? message;

  const _SyncWarning({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, color: Color(0xFFF97316), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'Backend notifications could not sync right now.',
              style: GoogleFonts.inter(
                color: FluentianColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _InboxNotification item;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;
    final accent = item.isLocal
        ? const Color(0xFFF97316)
        : FluentianColors.primary;
    final tint = item.isLocal
        ? const Color(0xFFFFF7ED)
        : FluentianColors.primaryTint;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnread
                  ? accent.withValues(alpha: 0.28)
                  : FluentianColors.border,
            ),
            boxShadow: [FluentianShadows.subtle],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUnread ? tint : FluentianColors.pageBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.isLocal ? Iconsax.mobile : Iconsax.notification,
                  size: 20,
                  color: isUnread ? accent : FluentianColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight:
                                  isUnread ? FontWeight.w900 : FontWeight.w700,
                              color: FluentianColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5, left: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.body,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.38,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SourcePill(
                          label: item.isLocal ? 'In-app' : 'Fluentian',
                          color: accent,
                          tint: tint,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDate(item.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textSecondary
                                  .withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year && local.month == now.month && local.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final wasYesterday = local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    if (sameDay) return 'Today at $hour:$minute';
    if (wasYesterday) return 'Yesterday at $hour:$minute';
    return '${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')} at $hour:$minute';
  }
}

class _SourcePill extends StatelessWidget {
  final String label;
  final Color color;
  final Color tint;

  const _SourcePill({
    required this.label,
    required this.color,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onAction?.call(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: FluentianColors.border),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: FluentianColors.primaryTint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 30, color: FluentianColors.primary),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: FluentianColors.textSecondary,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
