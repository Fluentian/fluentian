import 'dart:async';

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../services/social_api.dart';
import 'call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String title;

  const ChatDetailScreen({
    super.key,
    required this.roomId,
    required this.title,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _api = SocialApi.instance;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessageModel> _messages = const [];
  Timer? _pollTimer;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadMessages(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final messages = await _api.getChatMessages(widget.roomId);
      if (!mounted) return;
      final changed =
          messages.length != _messages.length ||
          (messages.isNotEmpty &&
              (_messages.isEmpty || messages.last.id != _messages.last.id));
      setState(() {
        _messages = messages;
        _loading = false;
        _error = null;
      });
      if (changed) _scrollToBottom();
    } catch (error) {
      if (!mounted || silent) return;
      setState(() {
        _loading = false;
        _error = error is ApiException ? error.userMessage : error.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final message = await _api.sendChatMessage(
        roomId: widget.roomId,
        body: body,
      );
      if (!mounted) return;
      _messageController.clear();
      setState(() {
        _messages = [..._messages, message];
        _sending = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error is ApiException ? error.userMessage : error.toString();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().user?.id;
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: LText(widget.title, style: GoogleFonts.ibmPlexSans(fontSize: 16)),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.call),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallScreen(topic: widget.title),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.video),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallScreen(topic: widget.title, isVideo: true),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: LText(_error!),
              actions: [
                TextButton(
                  onPressed: () => _loadMessages(),
                  child: const LText('Retry'),
                ),
                TextButton(
                  onPressed: () => setState(() => _error = null),
                  child: const LText('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const _EmptyChat()
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (_, index) {
                        final message = _messages[index];
                        return _MessageBubble(
                          message: message,
                          isMe: message.senderUserId == currentUserId,
                        );
                      },
                    ),
                  ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
    ),
    child: SafeArea(
      top: false,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_sending,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: context.tr('Write a friendly message'),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _sending ? null : _sendMessage,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.send_1, size: 20),
          ),
        ],
      ),
    ),
  );
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.message, size: 42, color: FluentianColors.primary),
          const SizedBox(height: 12),
          LText(
            'Start the conversation',
            style: GoogleFonts.ibmPlexSans(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          LText(
            'Messages sent here are shared with everyone in this room.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(color: FluentianColors.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final local = message.createdAt?.toLocal();
    final time = local == null
        ? ''
        : '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe ? FluentianColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(0).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : null,
            bottomLeft: isMe ? null : const Radius.circular(0),
          ),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            LText(
              message.body,
              style: GoogleFonts.ibmPlexSans(
                color: isMe ? Colors.white : FluentianColors.textPrimary,
                height: 1.35,
              ),
            ),
            if (time.isNotEmpty) ...[
              const SizedBox(height: 4),
              LText(
                time,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : FluentianColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
