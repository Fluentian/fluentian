import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../services/ai_service.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _modeIndex = 0;
  bool _isLoading = false;
  late List<_ChatMsg> _messages;
  final _modes = [
    'Free chat',
    'Roleplay',
    'Grammar drill',
    'Pronunciation',
    'Exam prep',
    'Culture',
  ];

  List<_ChatMsg> get _presetMessages {
    switch (_modeIndex) {
      case 1: // Roleplay
        return [
          _ChatMsg(
            false,
            'Bienvenue au Café de Paris ! Que désirez-vous commander ? ☕',
            null,
          ),
          _ChatMsg(
            true,
            'Bonjour ! Je voudrais un café au lait et un croissant, s\'il vous plaît.',
            null,
          ),
          _ChatMsg(
            false,
            'Très bien. Et avec ceci ? Peut-être une pâtisserie ? 🥐',
            null,
          ),
        ];
      case 2: // Grammar drill
        return [
          _ChatMsg(
            false,
            'Aujourd\'hui, nous allons pratiquer le subjonctif. Complète cette phrase : "Il faut que tu _______ (partir) maintenant."',
            null,
          ),
          _ChatMsg(true, 'Il faut que tu pars maintenant.', null),
          _ChatMsg(
            false,
            null,
            _Feedback(
              good: null,
              tip: 'The verb "partir" in the subjunctive is "partes".',
              fix: '✗ Correction: "pars" → "partes"',
            ),
          ),
          _ChatMsg(false, 'Essaie encore ! 📝', null),
        ];
      case 3: // Pronunciation
        return [
          _ChatMsg(
            false,
            'Répète après moi : "L\'écureuil est sur l\'arbre." 🐿️',
            null,
          ),
          _ChatMsg(true, '[Voice Message: L-ecure-uil...]', null),
          _ChatMsg(
            false,
            null,
            _Feedback(
              good: '✓ Good "L\'écureuil" vowel sound',
              tip: 'Work on the "r" in "arbre"',
              fix: null,
            ),
          ),
          _ChatMsg(
            false,
            'Ta prononciation s\'améliore ! Continue comme ça. 🔊',
            null,
          ),
        ];
      case 4: // Exam prep
        return [
          _ChatMsg(
            false,
            'Préparation au DELF B2. Écoute cet extrait et dis-moi l\'idée principale. 🎧',
            null,
          ),
          _ChatMsg(
            true,
            'L\'idée principale est l\'impact du télétravail sur l\'environnement.',
            null,
          ),
          _ChatMsg(
            false,
            'Exactement ! Quels arguments l\'intervenant utilise-t-il ?',
            null,
          ),
        ];
      case 5: // Culture
        return [
          _ChatMsg(
            false,
            'Savais-tu que la Fête de la Musique a lieu chaque 21 juin en France ? 🎸',
            null,
          ),
          _ChatMsg(
            true,
            'Non, je ne savais pas. C\'est quoi exactement ?',
            null,
          ),
          _ChatMsg(
            false,
            'C\'est une journée où tout le monde peut jouer de la musique dans les rues gratuitement ! 🎶',
            null,
          ),
        ];
      default: // Free chat
        return [
          _ChatMsg(
            false,
            'Bonjour ! Je suis Marie, ton coach IA. Comment ça va aujourd\'hui ? 😊',
            null,
          ),
          _ChatMsg(
            false,
            null,
            _Feedback(
              good: '✓ Good greeting structure',
              tip: 'Try using "Comment allez-vous?" for formal',
              fix: null,
            ),
          ),
          _ChatMsg(true, 'Bonjour Marie ! Je suis bien, merci.', null),
          _ChatMsg(
            false,
            'Très bien ! Petite correction : on dit "Je vais bien" plutôt que "Je suis bien". 📝',
            null,
          ),
          _ChatMsg(
            false,
            null,
            _Feedback(
              good: '✓ Good use of "merci"',
              tip: null,
              fix: '✗ Correction: "Je suis bien" → "Je vais bien"',
            ),
          ),
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _messages = List<_ChatMsg>.of(_presetMessages);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;
    setState(() {
      _messages.add(_ChatMsg(true, text, null));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToEnd();
    final response = await AiService.instance.generateText(
      messages: _messages
          .where((message) => message.text?.trim().isNotEmpty == true)
          .map(
            (message) => AiMessage(
              role: message.isUser ? 'user' : 'assistant',
              content: message.text!,
            ),
          )
          .toList(),
      systemContext:
          'Target language: French. Coaching mode: ${_modes[_modeIndex]}. '
          'Explanation language: ${AppLocaleController.activeLanguageName}. '
          'Help the learner practice French and explain corrections in the selected explanation language.',
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.add(
        _ChatMsg(
          false,
          response?.text ??
              context.tr('The AI tutor is unavailable. Please try again.'),
          null,
        ),
      );
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
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
    return Container(
      color: FluentianColors.darkNav,
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          FluentianColors.primaryLight,
                          FluentianColors.primary,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Iconsax.teacher,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(
                          'Marie — AI Coach',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        LText(
                          'A2 · Free conversation',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: FluentianColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Iconsax.setting_2,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),

            // Mode selector
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _modes.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() {
                    _modeIndex = i;
                    _messages = List<_ChatMsg>.of(_presetMessages);
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _modeIndex == i
                          ? FluentianColors.primary
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: _modeIndex != i
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: LText(
                      _modes[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _modeIndex == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.66),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Session stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _StatPill(Iconsax.message_text, '5 turns'),
                  const SizedBox(width: 8),
                  _StatPill(Iconsax.tick_circle, '82% accuracy'),
                  const SizedBox(width: 8),
                  _StatPill(Iconsax.edit_2, '3 corrections'),
                ],
              ),
            ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return const _CoachTypingPreview();
                  }
                  return _buildMessage(_messages[i]);
                },
              ),
            ),

            // Input bar
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 8,
                top: 8,
                bottom: 8 + MediaQuery.of(context).padding.bottom,
              ),
              color: FluentianColors.darkPageBg,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Iconsax.translate,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: FluentianColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: FluentianColors.darkBorder),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: context.tr('Write a sentence in French'),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: FluentianColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.microphone_2,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _isLoading ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.send_1,
                        color: _isLoading ? Colors.white38 : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(_ChatMsg msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 4, right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    FluentianColors.primaryLight,
                    FluentianColors.primary,
                  ],
                ),
              ),
              child: const Icon(Iconsax.teacher, color: Colors.white, size: 12),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? FluentianColors.primary
                    : FluentianColors.darkCard,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 18 : 4),
                  topRight: Radius.circular(isUser ? 4 : 18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                border: isUser
                    ? null
                    : Border.all(color: FluentianColors.darkBorder),
              ),
              child: msg.feedback != null
                  ? _buildFeedback(msg.feedback!)
                  : isUser
                  ? LText(
                      msg.text!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    )
                  : _CoachMarkdownResponse(msg.text!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(_Feedback fb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fb.good != null) _FeedbackChip(fb.good!, FluentianColors.success),
        if (fb.tip != null) _FeedbackChip(fb.tip!, FluentianColors.accent),
        if (fb.fix != null) _FeedbackChip(fb.fix!, FluentianColors.error),
      ],
    );
  }
}

class _CoachMarkdownResponse extends StatelessWidget {
  final String text;

  const _CoachMarkdownResponse(this.text);

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.inter(
      fontSize: 15,
      color: Colors.white,
      height: 1.42,
      fontWeight: FontWeight.w500,
    );

    return MarkdownBody(
      data: text.trim(),
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        strong: baseStyle.copyWith(fontWeight: FontWeight.w900),
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        h1: baseStyle.copyWith(fontSize: 19, fontWeight: FontWeight.w900),
        h2: baseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w900),
        h3: baseStyle.copyWith(fontSize: 15.5, fontWeight: FontWeight.w900),
        listBullet: baseStyle.copyWith(
          color: FluentianColors.primaryLight,
          fontWeight: FontWeight.w900,
        ),
        a: baseStyle.copyWith(
          color: FluentianColors.primaryLight,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.underline,
          decorationColor: FluentianColors.primaryLight,
        ),
        code: GoogleFonts.firaCode(
          color: FluentianColors.primaryLight,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        blockquote: baseStyle.copyWith(color: Colors.white70),
        blockquoteDecoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(color: FluentianColors.primaryLight, width: 4),
          ),
        ),
        blockquotePadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        blockSpacing: 10,
        listIndent: 20,
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  final String text;
  final Color color;
  const _FeedbackChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LText(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatPill(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.58)),
          const SizedBox(width: 5),
          LText(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachTypingPreview extends StatelessWidget {
  const _CoachTypingPreview();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 32, right: 36),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CoachThinkingDots(),
            const SizedBox(width: 10),
            Flexible(
              child: LText(
                'Marie is ready with hints, corrections, and examples',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.66),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachThinkingDots extends StatefulWidget {
  const _CoachThinkingDots();

  @override
  State<_CoachThinkingDots> createState() => _CoachThinkingDotsState();
}

class _CoachThinkingDotsState extends State<_CoachThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
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
            final value = math.sin(
              (_controller.value + index * 0.18) * math.pi * 2,
            );
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: FluentianColors.primaryLight.withValues(
                  alpha: 0.5 + (value + 1) * 0.22,
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _ChatMsg {
  final bool isUser;
  final String? text;
  final _Feedback? feedback;
  const _ChatMsg(this.isUser, this.text, this.feedback);
}

class _Feedback {
  final String? good, tip, fix;
  const _Feedback({this.good, this.tip, this.fix});
}
