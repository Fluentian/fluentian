import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/social_api.dart';

class CallScreen extends StatefulWidget {
  final String topic;
  final String? level;
  final bool isVideo;
  final bool smartMatch;
  final String? liveRoomId;

  const CallScreen({
    super.key,
    this.topic = 'French Corner',
    this.level,
    this.isVideo = false,
    this.smartMatch = false,
    this.liveRoomId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _SafetyAction extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool danger;
  const _SafetyAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (danger ? Colors.red : FluentianColors.primary)
                    .withValues(alpha: .17),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: danger
                    ? Colors.red.shade300
                    : FluentianColors.primaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    ),
  );
}

class _CallScreenState extends State<CallScreen> {
  final _socialApi = SocialApi.instance;
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  Timer? _timer;
  String? _matchTicketId;

  bool _isConnecting = true;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _speakerOn = true;
  bool _timerStarted = false;
  bool _isPrivateMatch = false;
  String? _error;
  String _status = 'Preparing your French speaking room...';
  String _roomName = '';
  String? _matchedTopic;
  String? _matchedLevel;
  String? _matchReason;
  int _remainingSeconds = 240;
  int _participantCount = 1;
  List<String> _prompts = const [];
  LocalVideoTrack? _localVideoTrack;
  RemoteVideoTrack? _remoteVideoTrack;

  @override
  void initState() {
    super.initState();
    _joinSpeakingRoom();
  }

  Future<void> _joinSpeakingRoom() async {
    try {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        throw Exception(
          'Microphone permission is required for audio practice.',
        );
      }
      if (widget.isVideo) {
        final camera = await Permission.camera.request();
        if (!camera.isGranted) {
          throw Exception('Camera permission is required for video practice.');
        }
      }

      final session = widget.liveRoomId == 'match'
          ? await _waitForMatch()
          : widget.liveRoomId != null
          ? await _socialApi.joinLiveRoom(
              roomId: widget.liveRoomId!,
              callKind: widget.isVideo ? 'video' : 'audio',
            )
          : await _socialApi.createSpeakingCall(
              topic: widget.topic,
              level: widget.level,
              callKind: widget.isVideo ? 'video' : 'audio',
              smartMatch: widget.smartMatch,
            );
      final room = Room();
      final listener = room.createListener()
        ..on<RoomConnectedEvent>((_) => _setStatus('Connected. Say bonjour!'))
        ..on<RoomReconnectingEvent>((_) => _setStatus('Reconnecting...'))
        ..on<RoomReconnectedEvent>((_) => _setStatus('Back in the room'))
        ..on<ParticipantConnectedEvent>((_) => _refreshParticipants())
        ..on<ParticipantDisconnectedEvent>((_) => _refreshParticipants())
        ..on<LocalTrackPublishedEvent>((event) {
          final track = event.publication.track;
          if (track is LocalVideoTrack) _setLocalVideo(track);
        })
        ..on<LocalTrackUnpublishedEvent>((event) {
          final track = event.publication.track;
          if (track is LocalVideoTrack && track == _localVideoTrack) {
            _setLocalVideo(null);
          }
        })
        ..on<TrackSubscribedEvent>((event) {
          final track = event.track;
          if (track is RemoteVideoTrack) _setRemoteVideo(track);
        })
        ..on<TrackUnsubscribedEvent>((event) {
          if (event.track == _remoteVideoTrack) _setRemoteVideo(null);
        })
        ..on<RoomDisconnectedEvent>((_) => _setStatus('Call ended'));

      setState(() {
        _room = room;
        _listener = listener;
        _roomName = session.providerRoomName;
        _matchedTopic = session.topic;
        _matchedLevel = session.level;
        _matchReason = session.matchReason;
        _prompts = session.prompts;
        _remainingSeconds = session.durationSeconds;
        _isPrivateMatch = widget.liveRoomId == 'match';
        _status = widget.smartMatch || widget.liveRoomId == 'match'
            ? 'Matched with ${session.level ?? 'your'} level speakers'
            : 'Joining ${widget.topic}...';
      });

      await room.connect(session.serverUrl, session.roomToken);
      await room.localParticipant?.setMicrophoneEnabled(true);
      if (widget.isVideo) {
        await room.localParticipant?.setCameraEnabled(true);
        _refreshLocalVideoTrack();
      }
      await room.setSpeakerOn(_speakerOn);
      _refreshParticipants();
      if (!_isPrivateMatch) _startTimer();

      if (mounted) {
        setState(() => _isConnecting = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _error = _formatCallError(e);
        _status = 'Could not join call';
      });
    }
  }

  Future<SpeakingCallSession> _waitForMatch() async {
    final callKind = widget.isVideo ? 'video' : 'audio';
    var result = await _socialApi.enterMatchQueue(callKind: callKind);
    _matchTicketId = result.ticketId;
    if (mounted) setState(() => _status = result.matchReason);

    final deadline = DateTime.now().add(const Duration(minutes: 2));
    while (!result.isMatched) {
      if (!mounted) throw Exception('Match cancelled.');
      if (DateTime.now().isAfter(deadline)) {
        final ticketId = _matchTicketId;
        _matchTicketId = null;
        if (ticketId != null) {
          await _socialApi.cancelMatchQueue(ticketId);
        }
        throw Exception('No partner joined yet. Please try again in a moment.');
      }
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) throw Exception('Match cancelled.');
      result = await _socialApi.pollMatchQueue(result.ticketId);
      if (mounted) setState(() => _status = result.matchReason);
    }

    _matchTicketId = null;
    return result.session!;
  }

  String _formatCallError(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 422 &&
          error.message.toLowerCase().contains('livekit is not configured')) {
        return 'Live speaking is not configured on the backend yet. Add LIVEKIT_API_KEY and LIVEKIT_API_SECRET on the server, then restart it.';
      }
      return error.userMessage;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _startTimer() {
    if (_timerStarted) return;
    _timer?.cancel();
    // A zero duration from open community rooms means unlimited, not expired.
    if (_remainingSeconds <= 0) return;
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        _leave();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _setStatus(String status) {
    if (mounted) setState(() => _status = status);
  }

  void _refreshParticipants() {
    final room = _room;
    if (room == null || !mounted) return;
    final count = room.remoteParticipants.length + 1;
    setState(() {
      _participantCount = count;
      if (_isPrivateMatch && count >= 2) {
        _status = 'Both learners are here. Your practice timer has started!';
      }
    });
    if (_isPrivateMatch && count >= 2) _startTimer();
  }

  void _setLocalVideo(LocalVideoTrack? track) {
    if (mounted) setState(() => _localVideoTrack = track);
  }

  void _setRemoteVideo(RemoteVideoTrack? track) {
    if (mounted) setState(() => _remoteVideoTrack = track);
  }

  void _refreshLocalVideoTrack() {
    final publications =
        _room?.localParticipant?.videoTrackPublications ?? const [];
    for (final publication in publications) {
      final track = publication.track;
      if (track is LocalVideoTrack) {
        _setLocalVideo(track);
        return;
      }
    }
  }

  Future<void> _toggleMute() async {
    final room = _room;
    if (room == null) return;
    final nextMuted = !_isMuted;
    await room.localParticipant?.setMicrophoneEnabled(!nextMuted);
    if (mounted) setState(() => _isMuted = nextMuted);
  }

  Future<void> _toggleSpeaker() async {
    final room = _room;
    if (room == null) return;
    final nextSpeaker = !_speakerOn;
    await room.setSpeakerOn(nextSpeaker);
    if (mounted) setState(() => _speakerOn = nextSpeaker);
  }

  Future<void> _toggleCamera() async {
    final room = _room;
    if (room == null || !widget.isVideo) return;
    final nextOff = !_isCameraOff;
    await room.localParticipant?.setCameraEnabled(!nextOff);
    if (!nextOff) {
      _refreshLocalVideoTrack();
    } else {
      _setLocalVideo(null);
    }
    if (mounted) setState(() => _isCameraOff = nextOff);
  }

  Future<void> _leave() async {
    _timer?.cancel();
    final ticketId = _matchTicketId;
    _matchTicketId = null;
    if (ticketId != null) {
      await _socialApi.cancelMatchQueue(ticketId);
    }
    await _listener?.dispose();
    await _room?.disconnect();
    await _room?.dispose();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    final ticketId = _matchTicketId;
    _matchTicketId = null;
    if (ticketId != null) {
      unawaited(_socialApi.cancelMatchQueue(ticketId));
    }
    _listener?.dispose();
    _room?.disconnect();
    _room?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final time = _remainingSeconds <= 0 ? 'LIVE' : '$minutes:$seconds';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101014),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              return Column(
                children: [
                  _buildHeader(wide: wide),
                  Expanded(
                    child: wide
                        ? _buildWideLayout(time)
                        : _buildPhoneLayout(time),
                  ),
                  _buildControls(wide: wide),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool wide}) {
    final title = _matchedTopic ?? widget.topic;
    return Padding(
      padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 12, wide ? 28 : 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: _leave,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: wide ? 18 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  _status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          _StatusPill(icon: Iconsax.profile_2user, label: '$_participantCount'),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Safety center',
            onPressed: _showSafetyCenter,
            icon: const Icon(Iconsax.shield_tick, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _showSafetyCenter() async {
    final participants =
        _room?.remoteParticipants.values.toList() ??
        const <RemoteParticipant>[];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1B1B22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: FluentianColors.primary.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Iconsax.shield_tick,
                      color: FluentianColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safety center',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'You are always in control of your room',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SafetyAction(
                icon: _speakerOn ? Iconsax.volume_slash : Iconsax.volume_high,
                title: _speakerOn ? 'Mute room audio' : 'Restore room audio',
                subtitle: 'Immediately stop or restore audio from everyone',
                onTap: () async {
                  await _toggleSpeaker();
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 9),
              _SafetyAction(
                icon: Iconsax.logout,
                title: 'Leave quietly',
                subtitle: 'Exit immediately without notifying the room',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _leave();
                },
              ),
              const SizedBox(height: 18),
              Text(
                'PEOPLE IN THIS ROOM',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              if (participants.isEmpty)
                Text(
                  'No other participants are connected yet.',
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                )
              else
                ...participants.map(
                  (participant) => _SafetyAction(
                    icon: Iconsax.profile_circle,
                    title: participant.name.isEmpty
                        ? 'Learner'
                        : participant.name,
                    subtitle: 'Report or block this person',
                    danger: true,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showReportSheet(participant);
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.info_circle,
                      color: FluentianColors.primaryLight,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reports are confidential. Blocking prevents future direct matching and is saved to your account.',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReportSheet(RemoteParticipant participant) async {
    String category = 'harassment';
    bool block = true, submitting = false;
    final details = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FluentianColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Report ${participant.name.isEmpty ? 'learner' : participant.name}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Choose the reason that best describes what happened.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FluentianColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    prefixIcon: Icon(Iconsax.warning_2),
                    border: OutlineInputBorder(),
                  ),
                  items:
                      const {
                            'harassment': 'Harassment or bullying',
                            'hate': 'Hate speech',
                            'sexual': 'Sexual content',
                            'spam': 'Spam or scam',
                            'impersonation': 'Impersonation',
                            'unsafe': 'Unsafe behavior',
                            'other': 'Something else',
                          }.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setSheetState(() => category = value);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: details,
                  maxLines: 3,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    labelText: 'What happened? (optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: block,
                  activeTrackColor: FluentianColors.primary,
                  title: const Text('Block this learner'),
                  subtitle: const Text('Avoid future direct matching'),
                  onChanged: (value) => setSheetState(() => block = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    onPressed: submitting
                        ? null
                        : () async {
                            setSheetState(() => submitting = true);
                            try {
                              await _socialApi.reportUser(
                                roomName: _roomName,
                                reportedUserId: participant.identity,
                                category: category,
                                details: details.text,
                                blockUser: block,
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Report received. Thank you for helping keep Fluentian safe.',
                                    ),
                                  ),
                                );
                              }
                            } catch (_) {
                              if (sheetContext.mounted) {
                                setSheetState(() => submitting = false);
                              }
                            }
                          },
                    icon: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Iconsax.shield_cross),
                    label: const Text('Submit confidential report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    details.dispose();
  }

  Widget _buildPhoneLayout(String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (widget.isVideo)
            _buildVideoStage(time)
          else
            _buildAudioStage(time, compact: true),
          const SizedBox(height: 16),
          _buildSessionStrip(),
          const SizedBox(height: 14),
          Expanded(child: _error != null ? _buildError() : _buildPromptPanel()),
        ],
      ),
    );
  }

  Widget _buildWideLayout(String time) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 22),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: widget.isVideo
                      ? _buildWideVideoStage(time)
                      : _buildAudioStage(time, compact: false),
                ),
                const SizedBox(height: 18),
                _buildSessionStrip(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 360,
            child: _error != null ? _buildError() : _buildPracticePanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(String time) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: FluentianColors.primaryLight, width: 3),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Center(
        child: Text(
          time,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomAvatar() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: FluentianColors.headerGradient,
        border: Border.all(color: Colors.white24, width: 4),
      ),
      child: const Icon(Iconsax.microphone_2, color: Colors.white, size: 46),
    );
  }

  Widget _buildAudioStage(String time, {required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 28,
        vertical: compact ? 20 : 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(compact ? 22 : 26),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimer(time),
          SizedBox(height: compact ? 18 : 26),
          _buildRoomAvatar(),
          SizedBox(height: compact ? 14 : 22),
          Text(
            '$_participantCount speaking now',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: compact ? 15 : 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _matchedLevel == null
                ? 'Guided French conversation'
                : '$_matchedLevel guided French conversation',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
          ),
          if (!compact) ...[const SizedBox(height: 30), _buildWaveform()],
        ],
      ),
    );
  }

  Widget _buildVideoStage(String time) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              height: 250,
              color: Colors.black,
              child: _remoteVideoTrack == null
                  ? Center(child: _buildRoomAvatar())
                  : VideoTrackRenderer(
                      _remoteVideoTrack!,
                      fit: VideoViewFit.cover,
                    ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 92,
                height: 126,
                color: const Color(0xFF1D1D22),
                child: _localVideoTrack == null
                    ? const Icon(Iconsax.video_slash, color: Colors.white54)
                    : VideoTrackRenderer(
                        _localVideoTrack!,
                        fit: VideoViewFit.cover,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideVideoStage(String time) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: _remoteVideoTrack == null
                ? Center(child: _buildAudioStage(time, compact: false))
                : VideoTrackRenderer(
                    _remoteVideoTrack!,
                    fit: VideoViewFit.cover,
                  ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: _StatusPill(icon: Iconsax.timer_1, label: time),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 150,
                height: 200,
                color: const Color(0xFF1D1D22),
                child: _localVideoTrack == null
                    ? const Icon(Iconsax.video_slash, color: Colors.white54)
                    : VideoTrackRenderer(
                        _localVideoTrack!,
                        fit: VideoViewFit.cover,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptPanel() {
    if (_isConnecting) {
      return const Center(
        child: CircularProgressIndicator(color: FluentianColors.primaryLight),
      );
    }

    final prompts = _prompts.isEmpty
        ? const [
            'Introduce yourself in French.',
            'Ask your partner one simple question.',
            'Say one sentence about today.',
          ]
        : _prompts;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            'Speaking prompts',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          if (_matchReason != null) ...[
            _buildMatchReason(),
            const SizedBox(height: 14),
          ],
          ...prompts.take(3).map(_buildPromptRow),
          const SizedBox(height: 8),
          _buildQuickActions(),
          const SizedBox(height: 14),
          Text(
            _roomName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticePanel() {
    if (_isConnecting) {
      return const Center(
        child: CircularProgressIndicator(color: FluentianColors.primaryLight),
      );
    }
    final prompts = _prompts.isEmpty
        ? const [
            'Introduce yourself in French.',
            'Ask your partner one simple question.',
            'Say one sentence about today.',
          ]
        : _prompts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            'Practice guide',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Use one prompt, then pass the turn.',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 18),
          if (_matchReason != null) ...[
            _buildMatchReason(),
            const SizedBox(height: 18),
          ],
          ...prompts.take(4).map(_buildPromptRow),
          const SizedBox(height: 12),
          _buildCallStatsGrid(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 14),
          Text(
            _roomName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptRow(String prompt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.message_question,
            color: FluentianColors.primaryLight,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              prompt,
              style: GoogleFonts.inter(color: Colors.white70, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchReason() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FluentianColors.primaryLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: FluentianColors.primaryLight.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.magic_star,
            color: FluentianColors.primaryLight,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _matchReason!,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FluentianColors.error.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: FluentianColors.error.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.warning_2,
              color: FluentianColors.error,
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white, height: 1.35),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isConnecting = true;
                });
                _joinSpeakingRoom();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls({required bool wide}) {
    return Container(
      padding: EdgeInsets.fromLTRB(wide ? 40 : 16, 14, wide ? 40 : 16, 18),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CallControl(
                  icon: _speakerOn ? Iconsax.volume_high : Iconsax.volume_slash,
                  tooltip: _speakerOn ? 'Speaker on' : 'Speaker off',
                  onTap: _room == null ? null : _toggleSpeaker,
                ),
                _ControlGap(wide: wide),
                _CallControl(
                  icon: _isMuted
                      ? Iconsax.microphone_slash
                      : Iconsax.microphone,
                  tooltip: _isMuted ? 'Unmute' : 'Mute',
                  isActive: !_isMuted,
                  onTap: _room == null ? null : _toggleMute,
                ),
                _ControlGap(wide: wide),
                if (widget.isVideo) ...[
                  _CallControl(
                    icon: _isCameraOff ? Iconsax.video_slash : Iconsax.video,
                    tooltip: _isCameraOff ? 'Camera off' : 'Camera on',
                    isActive: !_isCameraOff,
                    onTap: _room == null ? null : _toggleCamera,
                  ),
                  _ControlGap(wide: wide),
                ],
                _CallControl(
                  icon: Icons.call_end,
                  tooltip: 'End call',
                  backgroundColor: FluentianColors.error,
                  iconColor: Colors.white,
                  onTap: _leave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionStrip() {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Iconsax.microphone_2,
            label: _isMuted ? 'Muted' : 'Mic live',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Iconsax.profile_2user,
            label: '$_participantCount here',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            icon: Iconsax.flash_1,
            label: widget.isVideo ? 'Video room' : 'Audio room',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _SmallAction(icon: Iconsax.message_text, label: 'Prompt'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallAction(icon: Iconsax.teacher, label: 'Turn'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallAction(icon: Iconsax.star, label: 'Focus'),
        ),
      ],
    );
  }

  Widget _buildCallStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(icon: Iconsax.timer_1, label: '4 min sprint'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(icon: Iconsax.volume_high, label: 'Clear audio'),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    const bars = [
      0.26,
      0.58,
      0.42,
      0.72,
      0.36,
      0.64,
      0.92,
      0.48,
      0.74,
      0.38,
      0.68,
      0.52,
      0.84,
      0.45,
      0.62,
      0.78,
      0.34,
      0.56,
      0.88,
      0.46,
      0.7,
      0.4,
      0.6,
      0.76,
    ];
    return SizedBox(
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: bars
            .map(
              (height) => Container(
                width: 5,
                height: 46 * height,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ControlGap extends StatelessWidget {
  final bool wide;

  const _ControlGap({required this.wide});

  @override
  Widget build(BuildContext context) => SizedBox(width: wide ? 22 : 14);
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _CallControl({
    required this.icon,
    required this.tooltip,
    this.isActive = true,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        (isActive
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.06));
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: FluentianColors.primaryLight, size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SmallAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
