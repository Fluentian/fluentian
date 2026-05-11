import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _controller = TextEditingController();
  int _modeIndex = 0;
  final _modes = [
    'Free chat',
    'Roleplay',
    'Grammar drill',
    'Pronunciation',
    'Exam prep',
    'Culture',
  ];

  List<_ChatMsg> get _currentMessages {
    switch (_modeIndex) {
      case 1: // Roleplay
        return [
          _ChatMsg(false, 'Bienvenue au Café de Paris ! Que désirez-vous commander ? ☕', null),
          _ChatMsg(true, 'Bonjour ! Je voudrais un café au lait et un croissant, s\'il vous plaît.', null),
          _ChatMsg(false, 'Très bien. Et avec ceci ? Peut-être une pâtisserie ? 🥐', null),
        ];
      case 2: // Grammar drill
        return [
          _ChatMsg(false, 'Aujourd\'hui, nous allons pratiquer le subjonctif. Complète cette phrase : "Il faut que tu _______ (partir) maintenant."', null),
          _ChatMsg(true, 'Il faut que tu pars maintenant.', null),
          _ChatMsg(false, null, _Feedback(
            good: null,
            tip: 'The verb "partir" in the subjunctive is "partes".',
            fix: '✗ Correction: "pars" → "partes"',
          )),
          _ChatMsg(false, 'Essaie encore ! 📝', null),
        ];
      case 3: // Pronunciation
        return [
          _ChatMsg(false, 'Répète après moi : "L\'écureuil est sur l\'arbre." 🐿️', null),
          _ChatMsg(true, '[Voice Message: L-ecure-uil...]', null),
          _ChatMsg(false, null, _Feedback(
            good: '✓ Good "L\'écureuil" vowel sound',
            tip: 'Work on the "r" in "arbre"',
            fix: null,
          )),
          _ChatMsg(false, 'Ta prononciation s\'améliore ! Continue comme ça. 🔊', null),
        ];
      case 4: // Exam prep
        return [
          _ChatMsg(false, 'Préparation au DELF B2. Écoute cet extrait et dis-moi l\'idée principale. 🎧', null),
          _ChatMsg(true, 'L\'idée principale est l\'impact du télétravail sur l\'environnement.', null),
          _ChatMsg(false, 'Exactement ! Quels arguments l\'intervenant utilise-t-il ?', null),
        ];
      case 5: // Culture
        return [
          _ChatMsg(false, 'Savais-tu que la Fête de la Musique a lieu chaque 21 juin en France ? 🎸', null),
          _ChatMsg(true, 'Non, je ne savais pas. C\'est quoi exactement ?', null),
          _ChatMsg(false, 'C\'est une journée où tout le monde peut jouer de la musique dans les rues gratuitement ! 🎶', null),
        ];
      default: // Free chat
        return [
          _ChatMsg(false, 'Bonjour ! Je suis Marie, ton coach IA. Comment ça va aujourd\'hui ? 😊', null),
          _ChatMsg(false, null, _Feedback(
            good: '✓ Good greeting structure',
            tip: 'Try using "Comment allez-vous?" for formal',
            fix: null,
          )),
          _ChatMsg(true, 'Bonjour Marie ! Je suis bien, merci.', null),
          _ChatMsg(false, 'Très bien ! Petite correction : on dit "Je vais bien" plutôt que "Je suis bien". 📝', null),
          _ChatMsg(false, null, _Feedback(
            good: '✓ Good use of "merci"',
            tip: null,
            fix: '✗ Correction: "Je suis bien" → "Je vais bien"',
          )),
        ];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
                      Icons.waves_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marie — AI Coach',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'A2 · Free conversation',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: FluentianColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),

            // Mode selector
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _modes.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setState(() => _modeIndex = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _modeIndex == i
                          ? FluentianColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      border: _modeIndex != i
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _modes[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _modeIndex == i
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
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
                  _StatPill('5 turns'),
                  const SizedBox(width: 8),
                  _StatPill('82% accuracy'),
                  const SizedBox(width: 8),
                  _StatPill('3 corrections'),
                ],
              ),
            ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _currentMessages.length,
                itemBuilder: (_, i) => _buildMessage(_currentMessages[i]),
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
              color: const Color(0xFF120828),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.translate_rounded,
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
                      ),
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type in French...',
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
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
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
              child: const Icon(
                Icons.waves_rounded,
                color: Colors.white,
                size: 12,
              ),
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
                  : Text(
                      msg.text!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
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
      child: Text(
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
  final String text;
  const _StatPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
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
