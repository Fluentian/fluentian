import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../services/ai_service.dart';

class AiTutorSheet extends StatefulWidget {
  final String systemContext;
  final String initialPrompt;

  const AiTutorSheet({
    super.key,
    required this.systemContext,
    required this.initialPrompt,
  });

  static Future<void> show(
    BuildContext context, {
    required String systemContext,
    required String initialPrompt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AiTutorSheet(
          systemContext: systemContext,
          initialPrompt: initialPrompt,
        ),
      ),
    );
  }

  @override
  State<AiTutorSheet> createState() => _AiTutorSheetState();
}

class _AiTutorSheetState extends State<AiTutorSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendMessage(widget.initialPrompt, isInitial: true);
  }

  Future<void> _sendMessage(String text, {bool isInitial = false}) async {
    final msg = text.trim();
    if (msg.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(AiMessage(role: 'user', content: msg));
      if (!isInitial) _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    final aiResponse = await AiService.instance.generateText(
      messages: _messages,
      systemContext: widget.systemContext,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (aiResponse != null) {
          _messages.add(AiMessage(role: 'assistant', content: aiResponse));
        } else {
          _messages.add(
            AiMessage(
              role: 'assistant',
              content:
                  'I am having trouble connecting right now. Try again in a moment.',
            ),
          );
        }
      });
      _scrollToBottom();
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.78,
      decoration: BoxDecoration(
        color: FluentianColors.pageBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: FluentianColors.border),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: FluentianColors.headerGradient,
                  ),
                  child: const Icon(
                    Iconsax.teacher,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Tutor',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Get hints, examples, and cleaner explanations',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Iconsax.close_circle),
                  color: FluentianColors.textSecondary,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _PromptChip(
                  icon: Iconsax.magic_star,
                  label: 'Explain simply',
                  onTap: () => _sendMessage('Explain this in a simpler way.'),
                ),
                _PromptChip(
                  icon: Iconsax.lamp_charge,
                  label: 'Give example',
                  onTap: () => _sendMessage('Give me one clear example.'),
                ),
                _PromptChip(
                  icon: Iconsax.task_square,
                  label: 'Quiz me',
                  onTap: () =>
                      _sendMessage('Ask me a quick practice question.'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const _TypingBubble();
                }
                final msg = _messages[index];
                return _TutorMessageBubble(message: msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: FluentianColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    style: GoogleFonts.inter(
                      color: FluentianColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Iconsax.message_question,
                        size: 20,
                        color: FluentianColors.textSecondary,
                      ),
                      hintText: 'Ask for a hint or explanation...',
                      hintStyle: GoogleFonts.inter(
                        color: FluentianColors.textSecondary,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: FluentianColors.pageBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _isLoading ? null : _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _isLoading
                          ? null
                          : FluentianColors.headerGradient,
                      color: _isLoading ? Colors.grey.shade300 : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isLoading ? null : [FluentianShadows.subtle],
                    ),
                    child: IconButton(
                      tooltip: 'Send',
                      icon: const Icon(
                        Iconsax.send_1,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _sendMessage(_controller.text),
                    ),
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

class _PromptChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PromptChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FluentianColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: FluentianColors.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorMessageBubble extends StatelessWidget {
  final AiMessage message;

  const _TutorMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const _TutorAvatar(size: 30),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Container(
                padding: EdgeInsets.all(isUser ? 13 : 14),
                decoration: BoxDecoration(
                  color: isUser ? FluentianColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 18 : 6),
                    topRight: Radius.circular(isUser ? 6 : 18),
                    bottomLeft: const Radius.circular(18),
                    bottomRight: const Radius.circular(18),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: FluentianColors.border),
                  boxShadow: isUser ? null : [FluentianShadows.subtle],
                ),
                child: isUser
                    ? Text(
                        message.content,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.38,
                        ),
                      )
                    : _MarkdownTutorText(message.content),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownTutorText extends StatelessWidget {
  final String text;

  const _MarkdownTutorText(this.text);

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.inter(
      color: FluentianColors.textPrimary,
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      height: 1.5,
    );

    return MarkdownBody(
      data: text.trim(),
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        strong: baseStyle.copyWith(fontWeight: FontWeight.w900),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        h1: GoogleFonts.inter(
          color: FluentianColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          height: 1.25,
        ),
        h2: GoogleFonts.inter(
          color: FluentianColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1.28,
        ),
        h3: GoogleFonts.inter(
          color: FluentianColors.textPrimary,
          fontSize: 15.5,
          fontWeight: FontWeight.w900,
          height: 1.32,
        ),
        listBullet: GoogleFonts.inter(
          color: FluentianColors.primary,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          height: 1.45,
        ),
        code: GoogleFonts.firaCode(
          color: FluentianColors.primaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          backgroundColor: FluentianColors.primaryTint,
        ),
        codeblockDecoration: BoxDecoration(
          color: FluentianColors.primaryTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FluentianColors.primary.withValues(alpha: 0.14),
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        blockquote: baseStyle.copyWith(
          color: FluentianColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        blockquoteDecoration: BoxDecoration(
          color: FluentianColors.pageBg,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: FluentianColors.primary, width: 4),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        a: baseStyle.copyWith(
          color: FluentianColors.primary,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
          decorationColor: FluentianColors.primary,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: FluentianColors.border.withValues(alpha: 0.9),
            ),
          ),
        ),
        tableHead: baseStyle.copyWith(fontWeight: FontWeight.w900),
        tableBody: baseStyle.copyWith(fontSize: 13.5),
        tableBorder: TableBorder.all(color: FluentianColors.border),
        blockSpacing: 10,
        listIndent: 20,
        checkbox: baseStyle,
      ),
      bulletBuilder: (parameters) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.only(top: 8),
        decoration: const BoxDecoration(
          color: FluentianColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TutorAvatar(size: 30),
          SizedBox(width: 8),
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.fromBorderSide(
                  BorderSide(color: FluentianColors.border),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedDots(),
                    SizedBox(width: 10),
                    Text(
                      'Tutor is thinking',
                      style: TextStyle(
                        color: FluentianColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorAvatar extends StatelessWidget {
  final double size;

  const _TutorAvatar({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: FluentianColors.headerGradient,
      ),
      child: Icon(Iconsax.teacher, color: Colors.white, size: size * 0.52),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value + index * 0.18) * math.pi * 2;
            final scale = 0.72 + (math.sin(phase) + 1) * 0.14;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: FluentianColors.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
