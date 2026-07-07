import 'package:fluentian/screens/call_screen.dart';
import 'package:fluentian/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});
  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _filterIndex = 0;
  final _filters = ['All', 'A1-A2', 'B1-B2', 'C1+', 'My level'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Social',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.search_rounded,
                  color: FluentianColors.textSecondary,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active calls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Active calls',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _ActiveCallCard('French Corner', 4, null, [
                          FluentianColors.primary,
                          FluentianColors.accent,
                          FluentianColors.info,
                        ]),
                        _ActiveCallCard('Beginners Welcome', 2, 'A1', [
                          FluentianColors.success,
                          FluentianColors.primary,
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filter tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Chat rooms',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filters.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => setState(() => _filterIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _filterIndex == i
                                    ? FluentianColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _filters[i],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: _filterIndex == i
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _filterIndex == i
                                  ? FluentianColors.primary
                                  : FluentianColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Room list
                  ..._rooms.map(
                    (r) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(title: r.name),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Container(
                          height: 76,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: r.color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(r.icon, size: 20, color: r.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          r.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: FluentianColors.textPrimary,
                                          ),
                                        ),
                                        if (r.level != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: FluentianColors.primaryTint,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              r.level!,
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: FluentianColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${r.members} members · ${r.preview}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: FluentianColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (r.unread > 0)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: FluentianColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${r.unread}',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.time,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: FluentianColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FAB placeholder (would be a FloatingActionButton in real impl)
        ],
      ),
    );
  }
}

class _ActiveCallCard extends StatelessWidget {
  final String name;
  final int count;
  final String? level;
  final List<Color> colors;
  const _ActiveCallCard(this.name, this.count, this.level, this.colors);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(topic: name, level: level),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar stack
            SizedBox(
              height: 28,
              child: Stack(
                children: List.generate(
                  colors.length.clamp(0, 3),
                  (i) => Positioned(
                    left: i * 18.0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors[i],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FluentianColors.textPrimary,
              ),
            ),
            Text(
              '$count speaking now',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: FluentianColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _rooms = [
  _Room(
    'French Corner',
    Icons.group_rounded,
    FluentianColors.info,
    42,
    'Salut tout le monde!',
    3,
    '2m',
    null,
  ),
  _Room(
    'A2 Practice',
    Icons.school_rounded,
    FluentianColors.primary,
    18,
    'Let\'s practice...',
    0,
    '5m',
    'A2',
  ),
  _Room(
    'Grammar Help',
    Icons.edit_note_rounded,
    FluentianColors.accent,
    31,
    'Can anyone explain...',
    1,
    '12m',
    null,
  ),
  _Room(
    'Beginners Welcome',
    Icons.emoji_people_rounded,
    FluentianColors.success,
    56,
    'Welcome to the group!',
    5,
    '1h',
    'A1',
  ),
  _Room(
    'Exam Prep B2',
    Icons.quiz_rounded,
    FluentianColors.primary,
    12,
    'DELF B2 tips...',
    0,
    '3h',
    'B2',
  ),
];

class _Room {
  final String name, preview, time;
  final IconData icon;
  final Color color;
  final int members, unread;
  final String? level;
  const _Room(
    this.name,
    this.icon,
    this.color,
    this.members,
    this.preview,
    this.unread,
    this.time,
    this.level,
  );
}
