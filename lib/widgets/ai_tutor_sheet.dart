import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/ai_service.dart';
import '../services/sound_effect_service.dart';
import 'pronunciation_button.dart';

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
    if (!isInitial &&
        (context.read<AuthProvider>().user?.soundEnabled ?? true)) {
      SoundEffectService.instance.play(SoundEffect.aiResponse);
    }
    _scrollToBottom();

    final lowerMsg = msg.toLowerCase();
    String? quickActionType;
    if (lowerMsg.contains('summarize') || lowerMsg.contains('summary')) {
      quickActionType = 'summarize';
    } else if (lowerMsg.contains('example')) {
      quickActionType = 'example';
    } else if (lowerMsg.contains('quiz') || lowerMsg.contains('question')) {
      quickActionType = 'quiz';
    }

    AiTutorResponse? aiResponse;
    if (quickActionType != null && widget.systemContext.isNotEmpty) {
      final contentId = widget.systemContext.hashCode.toString();
      aiResponse = await AiService.instance.fetchQuickAction(
        action: quickActionType,
        contentId: contentId,
        contextText: widget.systemContext,
      );
    } else {
      aiResponse = await AiService.instance.generateText(
        messages: _messages,
        systemContext: widget.systemContext,
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (aiResponse != null) {
          _messages.add(
            AiMessage(
              role: 'assistant',
              content: aiResponse.text,
              activity: aiResponse.activity,
              keyPhrase: aiResponse.keyPhrase,
            ),
          );
          if (context.read<AuthProvider>().user?.soundEnabled ?? true) {
            SoundEffectService.instance.play(SoundEffect.aiResponse);
          }
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
        boxShadow: [
          FluentianShadows.subtle,
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
                color: FluentianColors.border,
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
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
                      LText(
                        'AI Tutor',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      LText(
                        'Get hints, examples, and cleaner explanations',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr('Close'),
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
                  onTap: () => _sendMessage(
                    'Quiz me on this French lesson. Create one clickable multiple-choice French quiz or a quick poll based on the lesson context. Include instant feedback and a short explanation.',
                  ),
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
                    style: GoogleFonts.ibmPlexSans(
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
                      hintText: context.tr(
                        'Ask why, request an example, or get a hint',
                      ),
                      hintStyle: GoogleFonts.ibmPlexSans(
                        color: FluentianColors.textSecondary,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
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
                      color: _isLoading ? FluentianColors.border : null,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: _isLoading ? null : [FluentianShadows.subtle],
                    ),
                    child: IconButton(
                      tooltip: context.tr('Send'),
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
        borderRadius: BorderRadius.circular(0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: FluentianColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: FluentianColors.primary),
                const SizedBox(width: 6),
                LText(
                  label,
                  style: GoogleFonts.ibmPlexSans(
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
                    bottomLeft: const Radius.circular(0),
                    bottomRight: const Radius.circular(0),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: FluentianColors.border),
                  boxShadow: isUser ? null : [FluentianShadows.subtle],
                ),
                child: isUser
                    ? LText(
                        message.content,
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          height: 1.38,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.content.trim().isNotEmpty)
                            _MarkdownTutorText(message.content),
                          if (message.activity != null) ...[
                            if (message.content.trim().isNotEmpty)
                              const SizedBox(height: 12),
                            _TutorActivityCard(activity: message.activity!),
                          ],
                          if (message.keyPhrase != null &&
                              message.keyPhrase!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            PronunciationButton(text: message.keyPhrase!),
                          ],
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

class _MarkdownTutorText extends StatelessWidget {
  final String text;

  const _MarkdownTutorText(this.text);

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.ibmPlexSans(
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
        strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        h1: GoogleFonts.ibmPlexSans(
          color: FluentianColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
        h2: GoogleFonts.ibmPlexSans(
          color: FluentianColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.28,
        ),
        h3: GoogleFonts.ibmPlexSans(
          color: FluentianColors.textPrimary,
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          height: 1.32,
        ),
        listBullet: GoogleFonts.ibmPlexSans(
          color: FluentianColors.primary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
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
          borderRadius: BorderRadius.circular(0),
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
          borderRadius: BorderRadius.circular(0),
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
        tableHead: baseStyle.copyWith(fontWeight: FontWeight.w700),
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

class _TutorActivityCard extends StatefulWidget {
  final AiTutorActivity activity;

  const _TutorActivityCard({required this.activity});

  @override
  State<_TutorActivityCard> createState() => _TutorActivityCardState();
}

class _TutorActivityCardState extends State<_TutorActivityCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final isPoll = activity.isPoll;
    final selectedOption = _selectedIndex == null
        ? null
        : activity.options[_selectedIndex!];
    final totalVotes = activity.options.fold<int>(
      0,
      (sum, option) => sum + (option.votes ?? 0),
    );
    final adjustedVotes = totalVotes + (_selectedIndex == null ? 0 : 1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FluentianColors.pageBg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: FluentianColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isPoll
                      ? FluentianColors.warningTint
                      : FluentianColors.primaryTint,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Icon(
                  isPoll ? Iconsax.chart_2 : Iconsax.task_square,
                  size: 17,
                  color: isPoll
                      ? FluentianColors.warning
                      : FluentianColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LText(
                  isPoll ? 'Quick poll' : 'Mini quiz',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    color: FluentianColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LText(
            activity.question,
            style: GoogleFonts.ibmPlexSans(
              color: FluentianColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(activity.options.length, (index) {
            final option = activity.options[index];
            final selected = _selectedIndex == index;
            final correct = option.isCorrect == true;
            final wrongSelection =
                selected &&
                option.isCorrect != null &&
                option.isCorrect == false;
            final showResult = _selectedIndex != null;
            final optionVotes =
                (option.votes ?? 0) + (selected && isPoll ? 1 : 0);
            final percent = adjustedVotes <= 0
                ? 0.0
                : optionVotes / adjustedVotes;
            final accent = isPoll
                ? FluentianColors.primary
                : correct
                ? FluentianColors.success
                : wrongSelection
                ? FluentianColors.error
                : FluentianColors.primary;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = index),
                  borderRadius: BorderRadius.circular(0),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: selected || (showResult && correct && !isPoll)
                            ? accent.withValues(alpha: 0.55)
                            : FluentianColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selected
                                  ? Iconsax.tick_circle
                                  : Iconsax.record_circle,
                              size: 18,
                              color: selected
                                  ? accent
                                  : FluentianColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LText(
                                option.text,
                                style: GoogleFonts.ibmPlexSans(
                                  color: FluentianColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isPoll && _selectedIndex != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 6,
                              backgroundColor: FluentianColors.border,
                              valueColor: AlwaysStoppedAnimation(accent),
                            ),
                          ),
                          const SizedBox(height: 5),
                          LText(
                            '${(percent * 100).round()}% chose this',
                            style: GoogleFonts.ibmPlexSans(
                              color: FluentianColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          if (_selectedIndex != null) ...[
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: FluentianColors.border),
              ),
              child: LText(
                [
                  if (!isPoll && selectedOption?.isCorrect == true) 'Correct!',
                  if (!isPoll && selectedOption?.isCorrect == false)
                    'Good try.',
                  if (selectedOption?.feedback?.trim().isNotEmpty == true)
                    selectedOption!.feedback!.trim(),
                  if (activity.explanation.trim().isNotEmpty)
                    activity.explanation.trim(),
                ].join(' '),
                style: GoogleFonts.ibmPlexSans(
                  color: FluentianColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
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
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
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
                    LText(
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
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honor reduced-motion: keep the dots static rather than pulsing.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
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
