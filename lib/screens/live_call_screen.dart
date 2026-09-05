import 'dart:async';

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/social_api.dart';
import 'call_screen.dart';
import 'ai_live_call_screen.dart';
import 'find_speaking_partner_screen.dart';
import '../widgets/common_widgets.dart';

class LiveCallScreen extends StatefulWidget {
  const LiveCallScreen({super.key});

  @override
  State<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends State<LiveCallScreen> {
  // Held as plain state (not re-wrapped in a fresh Future on every refresh)
  // so periodic background updates just patch this data in place -- feeding
  // FutureBuilder a *new* Future identity every 25s was resetting it to
  // ConnectionState.waiting each time, which briefly swapped the whole list
  // for a loading spinner even though the data was already available. That
  // was the actual "whole page refreshes" flash, not just a perception issue.
  List<LiveRoomModel>? _rooms;
  bool _isInitialLoading = true;
  Object? _error;
  List<AiScenario>? _scenarios;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _loadScenarios();
    _presenceTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _refresh(silent: true),
    );
  }

  Future<void> _loadScenarios() async {
    try {
      final scenarios = await SocialApi.instance.getAiScenarios();
      if (mounted) setState(() => _scenarios = scenarios);
    } catch (_) {
      if (mounted) setState(() => _scenarios = const []);
    }
  }

  Future<void> _loadInitial() async {
    try {
      final rooms = await SocialApi.instance.getLiveRooms();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _isInitialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isInitialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    unawaited(SocialApi.instance.leaveLiveRooms());
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      final rooms = await SocialApi.instance.getLiveRooms();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _error = null;
      });
    } catch (e) {
      if (!silent) rethrow;
    }
  }

  void _join(LiveRoomModel room, {bool video = false}) {
    if (!room.eligible || !room.isOpen) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          topic: room.title,
          isVideo: video,
          smartMatch: room.roomType == 'match',
          liveRoomId: room.id,
        ),
      ),
    );
  }

  void _findPartner(LiveRoomModel room) {
    // Deliberately does not gate on room.isOpen (a snapshot of "is anyone
    // waiting right now") -- that used to grey the button out entirely
    // whenever nobody happened to be online, with zero feedback. The
    // matching queue already has a proper timeout with a clear "no partner
    // joined yet" message; let that handle the no-one-available case
    // instead of hiding the entry point before the user can even try.
    if (!room.eligible) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FindSpeakingPartnerScreen(topic: room.title),
      ),
    );
  }

  Future<void> _startAiPractice() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    final result = await showModalBottomSheet<AiCallSettings>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AiCallSettingsSheet(
        speed: p.getDouble('ai_speed') ?? 1,
        level: p.getString('ai_level'),
        immersion: p.getBool('ai_immersion') ?? false,
        explanation: p.getString('ai_explanation') ?? 'English',
        voice: p.getString('ai_voice') ?? 'maya',
        personality: p.getString('ai_personality') ?? 'Warm',
        mood: p.getString('ai_mood') ?? 'Encouraging',
        register: p.getString('ai_register') ?? 'Natural',
        curveball: p.getBool('ai_curveball') ?? false,
      ),
    );
    if (result == null || !mounted) return;
    await p.setDouble('ai_speed', result.speed);
    if (result.level == null) {
      await p.remove('ai_level');
    } else {
      await p.setString('ai_level', result.level!);
    }
    await p.setBool('ai_immersion', result.immersion);
    await p.setString('ai_explanation', result.explanationLanguage);
    await p.setString('ai_voice', result.voice);
    await p.setString('ai_personality', result.personality);
    await p.setString('ai_mood', result.mood);
    await p.setString('ai_register', result.register);
    await p.setBool('ai_curveball', result.curveball);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AiLiveCallScreen(settings: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LText(
                        'Live practice',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LText(
                        'Practice with Marie or learners worldwide',
                        style: GoogleFonts.ibmPlexSans(
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
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: const Icon(
                    Iconsax.microphone_2,
                    color: FluentianColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_scenarios != null && _scenarios!.isNotEmpty)
              _ScenarioGallery(scenarios: _scenarios!),
            _AiTutorCard(onStart: _startAiPractice),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                if (_isInitialLoading) {
                  return const FluentianShimmer(child: SkeletonLiveRoom());
                }
                if (_error != null) {
                  final err = _error;
                  final detail = err is ApiException
                      ? err.userMessage
                      : 'Check your connection and try again.';
                  return _MessageCard(
                    message: 'Could not load live rooms. $detail',
                    onRetry: _refresh,
                  );
                }
                final rooms = _rooms ?? const [];
                if (rooms.isEmpty) {
                  return _MessageCard(
                    message: 'No live rooms are available.',
                    onRetry: _refresh,
                  );
                }
                final matches = rooms.where((r) => r.roomType == 'match');
                final special = rooms.where((r) => r.roomType == 'special');
                final eligible = rooms.where(
                  (r) =>
                      r.roomType != 'match' &&
                      r.roomType != 'special' &&
                      r.eligible,
                );
                final locked = rooms.where(
                  (r) =>
                      r.roomType != 'match' &&
                      r.roomType != 'special' &&
                      !r.eligible,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (matches.isNotEmpty)
                      _MatchCard(
                        room: matches.first,
                        onJoin: () => _findPartner(matches.first),
                      ),
                    if (special.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _RoomCard(
                        room: special.first,
                        onAudio: () => _join(special.first),
                        onVideo: () => _join(special.first, video: true),
                      ),
                    ],
                    const _Heading('Available for you now'),
                    ...eligible.map(
                      (r) => _RoomCard(
                        room: r,
                        onAudio: () => _join(r),
                        onVideo: () => _join(r, video: true),
                      ),
                    ),
                    const _Heading('Other communities'),
                    ...locked.map(
                      (r) => _RoomCard(room: r, onAudio: () {}, onVideo: () {}),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenarioGallery extends StatelessWidget {
  final List<AiScenario> scenarios;
  const _ScenarioGallery({required this.scenarios});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LText(
        'Choose a scenario',
        style: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: FluentianColors.textPrimary,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 164,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: scenarios.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final s = scenarios[i];
            return SizedBox(
              width: 238,
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(0),
                  onTap: () => _showRolePicker(context, s),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.ibmPlexSans(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                s.level,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          s.setting,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Goal: ${s.goal}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Future<void> _showRolePicker(BuildContext context, AiScenario scenario) async {
  var ai = 'Waiter';
  var learner = 'Customer';
  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, set) => AlertDialog(
        title: Text(scenario.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Goal: ${scenario.goal}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: ai,
              decoration: const InputDecoration(labelText: 'AI plays'),
              items: [
                'Waiter',
                'Receptionist',
                'Friend',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => set(() => ai = v!),
            ),
            DropdownButtonFormField<String>(
              initialValue: learner,
              decoration: const InputDecoration(labelText: 'You play'),
              items: [
                'Customer',
                'Guest',
                'Friend',
              ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => set(() => learner = v!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const LText('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiLiveCallScreen(
                    settings: AiCallSettings(
                      level: scenario.level.toLowerCase(),
                      scenarioId: scenario.id,
                      learnerRole: learner.toLowerCase() == 'customer'
                          ? 'traveler'
                          : 'student',
                    ),
                  ),
                ),
              );
            },
            child: const LText('Start scenario'),
          ),
        ],
      ),
    ),
  );
}

class _AiCallSettingsSheet extends StatefulWidget {
  final double speed;
  final String? level;
  final bool immersion;
  final String explanation;
  final String voice;
  final String personality;
  final String mood;
  final String register;
  final bool curveball;
  const _AiCallSettingsSheet({
    required this.speed,
    required this.level,
    required this.immersion,
    required this.explanation,
    required this.voice,
    required this.personality,
    required this.mood,
    required this.register,
    required this.curveball,
  });
  @override
  State<_AiCallSettingsSheet> createState() => _AiCallSettingsSheetState();
}

class _AiCallSettingsSheetState extends State<_AiCallSettingsSheet> {
  late double speed = widget.speed;
  late String? level = widget.level;
  late bool immersion = widget.immersion;
  late String explanation = widget.explanation,
      voice = widget.voice,
      personality = widget.personality,
      mood = widget.mood,
      register = widget.register;
  late bool curveball = widget.curveball;
  Widget _pick(
    String label,
    String value,
    List<String> values,
    void Function(String) set,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: context.tr(label),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0)),
      ),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) set(v);
      },
    ),
  );
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LText(
            'Before you start',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          LText(
            'Shape this practice around how you learn best.',
            style: GoogleFonts.ibmPlexSans(color: FluentianColors.textSecondary),
          ),
          const SizedBox(height: 20),
          LText(
            'Speaking speed',
            style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: speed,
            min: .6,
            max: 1.4,
            divisions: 8,
            label: '${speed.toStringAsFixed(1)}×',
            onChanged: (v) => setState(() => speed = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const LText('Slower'),
              Text(
                '${speed.toStringAsFixed(1)}×',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const LText('Faster'),
            ],
          ),
          const SizedBox(height: 16),
          _pick('Level', level ?? 'Auto', const [
            'Auto',
            'A0',
            'A1',
            'A2',
            'B1',
            'B2',
            'C1',
          ], (v) => setState(() => level = v == 'Auto' ? null : v)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: LText('Immersion mode'),
            subtitle: LText('Keep the conversation in French'),
            value: immersion,
            onChanged: (v) => setState(() => immersion = v),
          ),
          _pick('Explanation language', explanation, const [
            'English',
            'Amharic',
            'Afaan Oromo',
          ], (v) => setState(() => explanation = v)),
          _pick('Voice', voice, const [
            'maya',
            'claire',
            'marie',
          ], (v) => setState(() => voice = v)),
          _pick('Personality', personality, const [
            'Warm',
            'Direct',
            'Playful',
          ], (v) => setState(() => personality = v)),
          _pick('Mood', mood, const [
            'Encouraging',
            'Calm',
            'Energetic',
          ], (v) => setState(() => mood = v)),
          _pick('Register', register, const [
            'Natural',
            'Formal',
            'Casual',
          ], (v) => setState(() => register = v)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const LText('Curveball mode'),
            subtitle: const LText('Add a realistic surprise to the role-play'),
            value: curveball,
            onChanged: (v) => setState(() => curveball = v),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              icon: const Icon(Iconsax.microphone_2),
              label: const LText('Start practice'),
              onPressed: () => Navigator.pop(
                context,
                AiCallSettings(
                  speed: speed,
                  level: level,
                  immersion: immersion,
                  explanationLanguage: explanation,
                  voice: voice,
                  personality: personality,
                  mood: mood,
                  register: register,
                  curveball: curveball,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AiTutorCard extends StatelessWidget {
  final VoidCallback onStart;

  const _AiTutorCard({required this.onStart});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: FluentianColors.primary,
      boxShadow: [
        FluentianShadows.subtle,
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .13),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.auto_awesome, color: FluentianColors.onInkSuccess),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    'Practice with Marie',
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  LText(
                    'Your private AI French tutor',
                    style: GoogleFonts.ibmPlexSans(
                      color: FluentianColors.onInkMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: FluentianColors.onInkSuccess.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(99),
              ),
              child: LText(
                'ALWAYS READY',
                style: FluentianTheme.label(size: 9, color: FluentianColors.onInkSuccess),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LText(
          'Speak naturally, type when it is easier, and get gentle corrections matched to your level.',
          style: GoogleFonts.ibmPlexSans(
            color: FluentianColors.onInkMuted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton.icon(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FluentianColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            icon: const Icon(Iconsax.microphone_2, size: 19),
            label: LText(
              'Start private practice',
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 22, 0, 10),
    child: LText(
      text,
      style: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: FluentianColors.textPrimary,
      ),
    ),
  );
}

class _MatchCard extends StatelessWidget {
  final LiveRoomModel room;
  final VoidCallback? onJoin;
  const _MatchCard({required this.room, required this.onJoin});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: FluentianColors.headerGradient,
      borderRadius: BorderRadius.circular(0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Iconsax.people, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    room.title,
                    style: GoogleFonts.ibmPlexSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  LText(
                    'Private · 2 people · ${room.eligibilityLabel}',
                    style: GoogleFonts.ibmPlexSans(
                      color: FluentianColors.onInkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LText(
          room.description,
          style: GoogleFonts.ibmPlexSans(color: Colors.white, height: 1.4),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onJoin,
            icon: const Icon(Iconsax.call),
            label: const LText('Find my partner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: FluentianColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RoomCard extends StatelessWidget {
  final LiveRoomModel room;
  final VoidCallback onAudio, onVideo;
  const _RoomCard({
    required this.room,
    required this.onAudio,
    required this.onVideo,
  });
  @override
  Widget build(BuildContext context) {
    final enabled = room.eligible && room.isOpen;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : FluentianColors.pageBg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: FluentianColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FluentianColors.primaryTint,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Icon(
              room.roomType == 'streak'
                  ? Iconsax.flash_1
                  : room.roomType == 'special'
                  ? Iconsax.crown_1
                  : Iconsax.teacher,
              color: FluentianColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  room.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                LText(
                  enabled
                      ? '${room.eligibilityLabel} · Open now'
                      : room.isOpen
                      ? 'Locked · ${room.eligibilityLabel}'
                      : room.roomType != 'special'
                      ? 'Waiting for an eligible learner'
                      : room.scheduledAt == null
                      ? 'Closed by admin'
                      : 'Scheduled ${room.scheduledAt!.toLocal()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 11,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: enabled ? onAudio : null,
            icon: Icon(
              Iconsax.call,
              color: enabled
                  ? FluentianColors.primary
                  : FluentianColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
          IconButton(
            onPressed: enabled ? onVideo : null,
            icon: Icon(
              Iconsax.video,
              color: enabled
                  ? FluentianColors.primary
                  : FluentianColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _MessageCard({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(30),
    child: Column(
      children: [
        LText(message),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const LText('Retry')),
      ],
    ),
  );
}
