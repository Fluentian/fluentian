import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import 'call_screen.dart';

class ChatDetailScreen extends StatelessWidget {
  final String title;

  const ChatDetailScreen({super.key, this.title = 'Language Exchange Room'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.inter(fontSize: 16)),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.call),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CallScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.video),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CallScreen(isVideo: true),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: _getMockMessages(),
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  List<Widget> _getMockMessages() {
    if (title == 'French Corner') {
      return [
        _buildMessage('Salut tout le monde ! Comment ça va ?', isMe: false, time: '10:00 AM'),
        _buildMessage('Ça va très bien, merci ! Et toi ?', isMe: true, time: '10:02 AM'),
        _buildMessage('Super ! On parle de quoi aujourd\'hui ?', isMe: false, time: '10:05 AM'),
      ];
    } else if (title == 'Grammar Help') {
      return [
        _buildMessage('Can anyone explain the difference between "c\'est" and "il est" ?', isMe: false, time: '09:30 AM'),
        _buildMessage('Sure! Use "c\'est" + noun and "il est" + adjective.', isMe: true, time: '09:35 AM'),
        _buildMessage('Merci beaucoup ! That helps a lot.', isMe: false, time: '09:36 AM'),
      ];
    } else {
      return [
        _buildMessage('Hello! Is anyone here practicing $title?', isMe: false, time: '10:00 AM'),
        _buildMessage('Yes, I am! Let\'s chat.', isMe: true, time: '10:02 AM'),
        _buildMessage('Great! Let\'s start with basics.', isMe: false, time: '10:05 AM'),
      ];
    }
  }

  Widget _buildMessage(
    String text, {
    required bool isMe,
    required String time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? FluentianColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
          ),
          border: isMe
              ? null
              : Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                color: isMe ? Colors.white : FluentianColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isMe ? Colors.white70 : FluentianColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Iconsax.add,
                color: FluentianColors.textSecondary,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.inter(
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: FluentianColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
