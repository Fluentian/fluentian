import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/social_api.dart';
import 'call_screen.dart';

class LiveCallScreen extends StatefulWidget {
  const LiveCallScreen({super.key});

  @override
  State<LiveCallScreen> createState() => _LiveCallScreenState();
}

class _LiveCallScreenState extends State<LiveCallScreen> {
  late Future<List<LiveRoomModel>> _rooms;
  Timer? _presenceTimer;

  @override
  void initState() {
    super.initState();
    _rooms = SocialApi.instance.getLiveRooms();
    _presenceTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _refresh(silent: true),
    );
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    unawaited(SocialApi.instance.leaveLiveRooms());
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    final request = SocialApi.instance.getLiveRooms();
    if (!silent && mounted) {
      setState(() {
        _rooms = request;
      });
    }
    try {
      final rooms = await request;
      if (silent && mounted) {
        setState(() {
          _rooms = Future.value(rooms);
        });
      }
    } catch (_) {
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
                        'Rooms open when another learner is online',
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<LiveRoomModel>>(
              future: _rooms,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  final detail = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).userMessage
                      : 'Check your connection and try again.';
                  return _MessageCard(
                    message: 'Could not load live rooms. $detail',
                    onRetry: _refresh,
                  );
                }
                final rooms = snapshot.data ?? const [];
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
                        onJoin: matches.first.isOpen
                            ? () => _join(matches.first)
                            : null,
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

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 22, 0, 10),
    child: Text(
      text,
      style: GoogleFonts.inter(
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
      borderRadius: BorderRadius.circular(18),
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
                  Text(
                    room.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Private · 2 people · ${room.eligibilityLabel}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
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
        Text(
          room.description,
          style: GoogleFonts.inter(color: Colors.white, height: 1.4),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onJoin,
            icon: Icon(room.isOpen ? Iconsax.call : Iconsax.clock),
            label: Text(
              room.isOpen ? 'Find my partner' : 'Waiting for learners',
            ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FluentianColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: FluentianColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
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
                Text(
                  room.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
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
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (enabled) ...[
            IconButton(
              onPressed: onAudio,
              icon: const Icon(Iconsax.call, color: FluentianColors.primary),
            ),
            IconButton(
              onPressed: onVideo,
              icon: const Icon(Iconsax.video, color: FluentianColors.primary),
            ),
          ] else
            const Icon(Iconsax.lock, color: FluentianColors.textSecondary),
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
        Text(message),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
