import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../services/ai_service.dart';
import '../widgets/pronunciation_button.dart';

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

  /// The coach's genuine opening turn for each mode. These are real
  /// prompts inviting the learner to respond -- we never fabricate the
  /// learner's own replies or feedback on things they haven't said yet.
  List<_ChatMsg> get _presetMessages {
    switch (_modeIndex) {
      case 1: // Roleplay
        return [
          _ChatMsg(
            false,
            'Bienvenue au Café de Paris ! Que désirez-vous commander ? ☕',
          ),
        ];
      case 2: // Grammar drill
        return [
          _ChatMsg(
            false,
            'Pratiquons le subjonctif. Complète cette phrase : « Il faut que tu ______ (partir) maintenant. »',
          ),
        ];
      case 3: // Pronunciation
        return [
          _ChatMsg(
            false,
            'Répète après moi : « L\'écureuil est sur l\'arbre. » 🐿️ Enregistre-toi, puis dis-moi si tu veux des conseils.',
          ),
        ];
      case 4: // Exam prep
        return [
          _ChatMsg(
            false,
            'Préparation au DELF B2. Quel thème veux-tu travailler aujourd\'hui — compréhension, production écrite ou orale ? 🎧',
          ),
        ];
      case 5: // Culture
        return [
          _ChatMsg(
            false,
            'Savais-tu que la Fête de la Musique a lieu chaque 21 juin en France ? 🎸 Veux-tu en savoir plus ?',
          ),
        ];
      default: // Free chat
        return [
          _ChatMsg(
            false,
            'Bonjour ! Je suis Marie, ton coach IA. De quoi veux-tu parler aujourd\'hui ? 😊',
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
      _messages.add(_ChatMsg(true, text));
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
          keyPhrase: response?.keyPhrase,
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
    return Scaffold(
      backgroundColor: FluentianColors.darkNav,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: 'Back',
                  ),
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
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        LText(
                          'A2 · Free conversation',
                          style: GoogleFonts.ibmPlexSans(
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
                      borderRadius: BorderRadius.circular(0),
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
                      borderRadius: BorderRadius.circular(0),
                      border: _modeIndex != i
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: LText(
                      _modes[i],
                      style: GoogleFonts.ibmPlexSans(
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
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: FluentianColors.darkCard,
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(color: FluentianColors.darkBorder),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: context.tr('Write a sentence in French'),
                          hintStyle: GoogleFonts.ibmPlexSans(
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
                  bottomLeft: const Radius.circular(0),
                  bottomRight: const Radius.circular(0),
                ),
                border: isUser
                    ? null
                    : Border.all(color: FluentianColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isUser
                      ? LText(
                          msg.text!,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      : _CoachMarkdownResponse(msg.text!),
                  if (!isUser &&
                      msg.keyPhrase != null &&
                      msg.keyPhrase!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    PronunciationButton(text: msg.keyPhrase!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _CoachMarkdownResponse extends StatelessWidget {
  final String text;

  const _CoachMarkdownResponse(this.text);

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.ibmPlexSans(
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
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        blockquote: baseStyle.copyWith(color: Colors.white70),
        blockquoteDecoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(0),
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
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.58)),
          const SizedBox(width: 5),
          LText(
            text,
            style: GoogleFonts.ibmPlexSans(
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
          borderRadius: BorderRadius.circular(0),
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
                style: GoogleFonts.ibmPlexSans(
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
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honor reduced-motion: keep the thinking dots static.
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
  final String? keyPhrase;
  const _ChatMsg(this.isUser, this.text, {this.keyPhrase});
}
