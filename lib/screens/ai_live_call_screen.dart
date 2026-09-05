import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/social_api.dart';
import '../services/product_analytics.dart';
import 'ai_call_report_screen.dart';

class AiCallSettings {
  final double speed;
  final String? level;
  final bool immersion;
  final String explanationLanguage;
  final String voice;
  final String personality;
  final String mood;
  final String register;
  final String? scenarioId;
  final String? learnerRole;
  final bool curveball;
  const AiCallSettings({
    this.speed = 1.0,
    this.level,
    this.immersion = false,
    this.explanationLanguage = 'English',
    this.voice = 'maya',
    this.personality = 'Warm',
    this.mood = 'Encouraging',
    this.register = 'Natural',
    this.scenarioId,
    this.learnerRole,
    this.curveball = false,
  });
}

class AiLiveCallScreen extends StatefulWidget {
  final AiCallSettings settings;
  const AiLiveCallScreen({super.key, this.settings = const AiCallSettings()});

  @override
  State<AiLiveCallScreen> createState() => _AiLiveCallScreenState();
}

class _AiLiveCallScreenState extends State<AiLiveCallScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Session? _session;
  Timer? _timer;
  bool _isStarting = true;
  bool _isMuted = false;
  bool _speakerOn = true;
  bool _isSending = false;
  bool _isLeaving = false;
  String? _error;
  bool _permissionPermanentlyDenied = false;
  int _remainingSeconds = 600;
  List<String> _prompts = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final approved = await _confirmAiMediaUse();
    if (!approved || !mounted) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      _permissionPermanentlyDenied = permission.isPermanentlyDenied;
      _setError('Microphone permission is required for live voice practice.');
      return;
    }

    try {
      if (widget.settings.scenarioId != null) {
        ProductAnalytics.instance.scenarioStarted(widget.settings.scenarioId!);
      } else if (widget.settings.speed != 1.0 || widget.settings.voice != 'maya' ||
          widget.settings.personality != 'Warm' || widget.settings.mood != 'Encouraging') {
        ProductAnalytics.instance.aiCallCustomized();
      }
      final call = await SocialApi.instance.createAiCall(
        speed: widget.settings.speed,
        level: widget.settings.level,
        immersion: widget.settings.immersion,
        explanationLanguage: widget.settings.explanationLanguage,
        voice: widget.settings.voice,
        personality: widget.settings.personality,
        mood: widget.settings.mood,
        register: widget.settings.register,
        scenarioId: widget.settings.scenarioId,
        learnerRole: widget.settings.learnerRole,
        curveball: widget.settings.curveball,
      );
      if (!mounted) return;

      final session = Session.fromFixedTokenSource(
        LiteralTokenSource(
          serverUrl: call.serverUrl,
          participantToken: call.roomToken,
          roomName: call.providerRoomName,
        ),
        options: SessionOptions(
          // preConnectAudio publishes a buffered mic track on participant-join,
          // a second publisher offer whose m-line order flutter_webrtc 1.4.0
          // rejects ("order of m-lines in subsequent offer doesn't match") —
          // the negotiation fails and the tutor never receives audio. Connect
          // first, then enable the mic (the sequence the speaking rooms already
          // use reliably). We only lose ~1-2s of pre-connect buffering, and
          // _waitForAgent blocks until the tutor is ready regardless.
          preConnectAudio: false,
          agentConnectTimeout: const Duration(seconds: 25),
        ),
      );
      session.addListener(_onSessionChanged);
      setState(() {
        _session = session;
        _remainingSeconds = call.durationSeconds;
        _prompts = call.prompts;
      });

      await session.start();
      if (!mounted) return;
      await _waitForAgent(session);
      if (!mounted) return;
      await session.room.setSpeakerOn(true);
      setState(() => _isStarting = false);
      _startTimer();
    } catch (error) {
      final failedSession = _session;
      _session = null;
      failedSession?.removeListener(_onSessionChanged);
      if (failedSession != null) await _disposeSession(failedSession);
      _setError(_formatError(error));
    }
  }

  Future<void> _waitForAgent(Session session) async {
    if (session.error != null) throw StateError('LiveKit connection failed');
    if (session.agent.isConnected) return;

    final ready = Completer<void>();
    void checkState() {
      if (ready.isCompleted) return;
      if (session.error != null || session.agent.error != null) {
        ready.completeError(StateError('Marie could not join the room'));
      } else if (session.agent.isConnected) {
        ready.complete();
      }
    }

    session.addListener(checkState);
    checkState();
    try {
      await ready.future.timeout(const Duration(seconds: 26));
    } finally {
      session.removeListener(checkState);
    }
  }

  Future<bool> _confirmAiMediaUse() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(
              Icons.auto_awesome,
              color: FluentianColors.secondary,
            ),
            title: Text(dialogContext.tr('Private AI voice practice')),
            content: Text(
              dialogContext.tr(
                'Your microphone audio is sent through LiveKit. Cartesia transcribes and speaks, and Gemini creates the tutor reply. Fluentian does not record the call. You can mute or leave at any time.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogContext.tr('Not now')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(dialogContext.tr('Start practice')),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onSessionChanged() {
    if (!mounted) return;
    final session = _session;
    setState(() {
      if (session?.error != null || session?.agent.error != null) {
        _error = 'The tutor connection was interrupted. Please try again.';
      } else if (!_isStarting && !_isLeaving && session?.isConnected == false) {
        _error = 'The tutor disconnected. Please start a new practice call.';
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        unawaited(_leave());
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _isStarting = false;
    });
  }

  String _formatError(Object error) {
    if (error is ApiException) return error.userMessage;
    if (kDebugMode) debugPrint('AI live call failed: $error');
    return 'Marie could not join right now. Check your connection and try again.';
  }

  String get _agentStatus {
    if (_error != null) return 'UNAVAILABLE';
    if (_isStarting) return 'CONNECTING';
    final agent = _session?.agent;
    if (agent?.error == AgentFailure.timeout) return 'UNAVAILABLE';
    return switch (agent?.agentState) {
      AgentState.listening => 'LISTENING',
      AgentState.thinking => 'THINKING',
      AgentState.speaking => 'SPEAKING',
      AgentState.initializing || AgentState.idle || null => 'GETTING READY',
    };
  }

  Color get _agentColor {
    if (_error != null) return const Color(0xFFF5C86B);
    return switch (_session?.agent.agentState) {
      AgentState.speaking => const Color(0xFF74DDD7),
      AgentState.thinking => const Color(0xFFF5C86B),
      _ => const Color(0xFF8BB8E8),
    };
  }

  Future<void> _send([String? suggestedText]) async {
    final text = (suggestedText ?? _messageController.text).trim();
    final session = _session;
    if (text.isEmpty || session == null || !session.isConnected || _isSending) {
      return;
    }
    final boundedText = text.length > 600 ? text.substring(0, 600) : text;
    setState(() => _isSending = true);
    _messageController.clear();
    final message = await session.sendText(boundedText);
    if (!mounted) return;
    setState(() {
      _isSending = false;
      if (message == null) {
        _error = 'Your message was not sent. Check the connection.';
      }
    });
    _scrollToLatest();
  }

  Future<void> _toggleMute() async {
    final participant = _session?.room.localParticipant;
    if (participant == null) return;
    final next = !_isMuted;
    await participant.setMicrophoneEnabled(!next);
    if (mounted) setState(() => _isMuted = next);
  }

  Future<void> _toggleSpeaker() async {
    final room = _session?.room;
    if (room == null) return;
    final next = !_speakerOn;
    await room.setSpeakerOn(next);
    if (mounted) setState(() => _speakerOn = next);
  }

  Future<void> _leave() async {
    if (_isLeaving) return;
    _isLeaving = true;
    _timer?.cancel();
    final session = _session;
    final transcript =
        session?.messages
            .map(
              (m) => <String, String>{
                'role': m.content is UserTranscript || m.content is UserInput
                    ? 'user'
                    : 'assistant',
                'content': m.content.text,
              },
            )
            .toList() ??
        const <Map<String, String>>[];
    final callId = session?.room.name;
    _session = null;
    session?.removeListener(_onSessionChanged);
    try {
      await session?.end().timeout(const Duration(seconds: 3));
    } catch (_) {
      // A failed or half-open room must never trap the learner on this screen.
    } finally {
      try {
        await session?.dispose();
      } catch (_) {
        // Disposal is best-effort after a transport failure.
      }
      if (mounted && callId != null && transcript.isNotEmpty) {
        try {
          final report = await SocialApi.instance.createAiCallReport(
            callId: callId,
            topic: widget.settings.scenarioId,
            scenarioId: widget.settings.scenarioId,
            learnerRole: widget.settings.learnerRole,
            transcript: transcript,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AiCallReportScreen(report: report),
              ),
            );
            return;
          }
        } catch (_) {}
      }
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _disposeSession(Session session) async {
    try {
      await session.end().timeout(const Duration(seconds: 3));
    } catch (_) {
      // The widget can be disposed while LiveKit is already disconnected.
    } finally {
      try {
        await session.dispose();
      } catch (_) {
        // Disposal is best-effort after a transport failure.
      }
    }
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    final session = _session;
    session?.removeListener(_onSessionChanged);
    if (session != null) unawaited(_disposeSession(session));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final messages = _session?.messages ?? const <ReceivedMessage>[];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF0B1018),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader('$minutes:$seconds'),
              _buildAgentStage(),
              Expanded(
                child: _error != null
                    ? _buildError()
                    : _buildConversation(messages),
              ),
              if (_error == null) _buildComposer(),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String time) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 16, 6),
    child: Row(
      children: [
        IconButton(
          tooltip: context.tr('Leave practice'),
          onPressed: _leave,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Marie',
                style: GoogleFonts.newsreader(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              LText(
                'Private French tutor',
                style: GoogleFonts.ibmPlexSans(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            time,
            style: GoogleFonts.ibmPlexSans(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildAgentStage() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
    child: Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _agentColor.withValues(alpha: .11),
            border: Border.all(
              color: _agentColor.withValues(alpha: .55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _agentColor.withValues(alpha: .17),
                blurRadius: _session?.agent.agentState == AgentState.speaking
                    ? 30
                    : 16,
                spreadRadius: _session?.agent.agentState == AgentState.speaking
                    ? 7
                    : 2,
              ),
            ],
          ),
          child: Center(
            child: _isStarting
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _agentColor,
                    ),
                  )
                : Icon(Icons.graphic_eq_rounded, color: _agentColor, size: 42),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            _agentStatus,
            key: ValueKey(_agentStatus),
            style: GoogleFonts.ibmPlexSans(
              color: _agentColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.7,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildConversation(List<ReceivedMessage> messages) {
    if (messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        children: [
          LText(
            _isStarting
                ? 'Marie is joining your room. You can begin speaking as soon as she says bonjour.'
                : 'Say bonjour, or choose a way to begin.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: Colors.white54,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          ..._prompts
              .take(3)
              .map(
                (prompt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: _isStarting ? null : () => _send(prompt),
                    borderRadius: BorderRadius.circular(0),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .055),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.message_question,
                            color: Color(0xFF74DDD7),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              prompt,
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser =
            message.content is UserInput || message.content is UserTranscript;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 330),
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isUser
                  ? FluentianColors.primary
                  : Colors.white.withValues(alpha: .075),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(0),
                topRight: const Radius.circular(0),
                bottomLeft: Radius.circular(isUser ? 17 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 17),
              ),
              border: isUser ? null : Border.all(color: Colors.white10),
            ),
            child: Text(
              message.content.text,
              style: GoogleFonts.ibmPlexSans(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() => Padding(
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
    child: Container(
      padding: const EdgeInsets.fromLTRB(14, 3, 5, 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .075),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isStarting && _session?.agent.isConnected == true,
              maxLength: 600,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              style: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: context.tr('Type to Marie…'),
                counterText: '',
                hintStyle: GoogleFonts.ibmPlexSans(
                  color: Colors.white38,
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton.filled(
            tooltip: context.tr('Send message'),
            onPressed: _isStarting || _isSending ? null : _send,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF74DDD7),
              foregroundColor: FluentianColors.primaryDark,
              disabledBackgroundColor: Colors.white10,
            ),
            icon: _isSending
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_upward_rounded, size: 20),
          ),
        ],
      ),
    ),
  );

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
    decoration: const BoxDecoration(
      color: Color(0xFF0E151F),
      border: Border(top: BorderSide(color: Colors.white10)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CallControl(
          icon: _speakerOn ? Iconsax.volume_high : Iconsax.volume_slash,
          label: _speakerOn ? 'Speaker' : 'Silent',
          onTap: _session == null ? null : _toggleSpeaker,
        ),
        const SizedBox(width: 18),
        _CallControl(
          icon: _isMuted ? Iconsax.microphone_slash : Iconsax.microphone_2,
          label: _isMuted ? 'Unmute' : 'Mute',
          active: _isMuted,
          onTap: _session == null ? null : _toggleMute,
        ),
        const SizedBox(width: 18),
        _CallControl(
          icon: Icons.call_end_rounded,
          label: 'Leave',
          danger: true,
          onTap: _leave,
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.info_circle, color: Color(0xFFF5C86B), size: 34),
          const SizedBox(height: 12),
          LText(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              if (_permissionPermanentlyDenied)
                FilledButton(
                  onPressed: openAppSettings,
                  child: const LText('Open settings'),
                ),
              OutlinedButton(
                onPressed: _leave,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const LText('Go back'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool danger;

  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.tr(label),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: danger
                    ? const Color(0xFFD94242)
                    : active
                    ? Colors.white
                    : Colors.white.withValues(alpha: .09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: danger
                    ? Colors.white
                    : active
                    ? const Color(0xFF0B1018)
                    : Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(height: 5),
            LText(
              label,
              style: GoogleFonts.ibmPlexSans(
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
