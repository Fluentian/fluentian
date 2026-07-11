import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme.dart';
import 'call_screen.dart';

class LiveCallScreen extends StatelessWidget {
  const LiveCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live practice',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join short French speaking rooms',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FluentianColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.microphone_2,
                  color: FluentianColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _LiveHero(
            onStart: () =>
                _openCall(context, topic: 'Everyday French', smartMatch: true),
          ),
          const SizedBox(height: 22),
          Text(
            'Speaking rooms',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._topics.map((topic) => _TopicTile(topic: topic)),
        ],
      ),
    );
  }

  static void _openCall(
    BuildContext context, {
    required String topic,
    String? level,
    bool isVideo = false,
    bool smartMatch = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          topic: topic,
          level: level,
          isVideo: isVideo,
          smartMatch: smartMatch,
        ),
      ),
    );
  }
}

class _LiveHero extends StatelessWidget {
  final VoidCallback onStart;

  const _LiveHero({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: FluentianColors.headerGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.volume_high,
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
                      'Smart match',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Find the best room for your level',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Iconsax.call, size: 19),
              label: const Text('Find my speaking partner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FluentianColors.primary,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final _LiveTopic topic;

  const _TopicTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FluentianColors.border),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: topic.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(topic.icon, color: topic.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          topic.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: FluentianColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (topic.level != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FluentianColors.primaryTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            topic.level!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: FluentianColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    topic.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: FluentianColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RoundAction(
              icon: Iconsax.call,
              tooltip: 'Audio',
              onTap: () => LiveCallScreen._openCall(
                context,
                topic: topic.title,
                level: topic.level,
              ),
            ),
            const SizedBox(width: 8),
            _RoundAction(
              icon: Iconsax.video,
              tooltip: 'Video',
              onTap: () => LiveCallScreen._openCall(
                context,
                topic: topic.title,
                level: topic.level,
                isVideo: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: FluentianColors.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: FluentianColors.primary, size: 19),
        ),
      ),
    );
  }
}

class _LiveTopic {
  final String title;
  final String subtitle;
  final String? level;
  final IconData icon;
  final Color color;

  const _LiveTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.level,
  });
}

const _topics = [
  _LiveTopic(
    title: 'French Corner',
    subtitle: 'Open conversation with guided prompts',
    icon: Iconsax.people,
    color: FluentianColors.primary,
  ),
  _LiveTopic(
    title: 'Beginners Welcome',
    subtitle: 'Greetings, names, numbers, and simple questions',
    level: 'A1',
    icon: Iconsax.emoji_happy,
    color: FluentianColors.success,
  ),
  _LiveTopic(
    title: 'A2 Practice',
    subtitle: 'Daily routines, cafes, and weekend plans',
    level: 'A2',
    icon: Iconsax.teacher,
    color: FluentianColors.info,
  ),
];
