import 'package:fluentian/screens/call_screen.dart';
import 'package:fluentian/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/social_api.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _api = SocialApi.instance;
  final _searchController = TextEditingController();
  bool _loading = true;
  String? _error;
  List<FriendSummary> _friends = const [];
  List<FriendRequest> _requests = const [];
  List<FriendActivity> _activity = const [];
  List<FriendChallenge> _challenges = const [];
  List<AccountabilityPartnership> _partnerships = const [];
  List<ChatRoomModel> _chatRooms = const [];

  @override
  void initState() {
    super.initState();
    _loadSocialGraph();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSocialGraph() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        _api.getFriends(),
        _api.getFriendRequests(),
        _api.getFriendActivity(),
        _api.getChallenges(),
        _api.getChatRooms(),
        _api.getPartnerships(),
      ]);
      if (!mounted) return;
      setState(() {
        _friends = results[0] as List<FriendSummary>;
        _requests = results[1] as List<FriendRequest>;
        _activity = results[2] as List<FriendActivity>;
        _challenges = results[3] as List<FriendChallenge>;
        _chatRooms = results[4] as List<ChatRoomModel>;
        _partnerships = results[5] as List<AccountabilityPartnership>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.userMessage : e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadSocialGraph,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildHero(),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _loading
                  ? const _SocialLoading()
                  : _error != null
                  ? _ErrorPanel(message: _error!, onRetry: _loadSocialGraph)
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Social',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Friends, progress, and friendly challenges',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _IconButton(
          icon: Iconsax.user_add,
          tooltip: 'Add friend',
          onTap: _showAddFriendSheet,
        ),
      ],
    );
  }

  Widget _buildHero() {
    final friendCount = _friends.length;
    final activeChallenges = _challenges
        .where((item) => item.status == 'active' || item.status == 'pending')
        .length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: FluentianColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.people, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Build your French circle',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroStat(label: 'Friends', value: '$friendCount'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroStat(
                  label: 'Challenges',
                  value: '$activeChallenges',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _showAddFriendSheet,
              icon: const Icon(Iconsax.search_normal_1, size: 18),
              label: const Text('Find classmates'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FluentianColors.primary,
                elevation: 0,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final incoming = _requests.where((item) => item.isIncoming).toList();
    final outgoing = _requests.where((item) => !item.isIncoming).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (incoming.isNotEmpty) ...[
          _SectionTitle(
            title: 'Friend requests',
            action: '${incoming.length} new',
          ),
          const SizedBox(height: 10),
          ...incoming.map(_buildRequestCard),
          const SizedBox(height: 18),
        ],
        if (outgoing.isNotEmpty) ...[
          _SectionTitle(
            title: 'Sent requests',
            action: '${outgoing.length} pending',
          ),
          const SizedBox(height: 10),
          ...outgoing.map(_buildRequestCard),
          const SizedBox(height: 18),
        ],
        _SectionTitle(
          title: 'Accountability partners',
          action:
              '${_partnerships.where((item) => item.status == 'active').length} active',
        ),
        const SizedBox(height: 10),
        if (_partnerships.isEmpty)
          _EmptyPanel(
            icon: Iconsax.people,
            title: 'Reach your goals together',
            body:
                'Invite a friend, choose a shared weekly goal, and keep each other moving.',
            actionLabel: _friends.isEmpty ? null : 'Choose a partner',
            onAction: _friends.isEmpty ? null : _showPartnerSheet,
          )
        else
          ..._partnerships.take(4).map(_buildPartnershipCard),
        const SizedBox(height: 18),
        _SectionTitle(title: 'Friends', action: '${_friends.length} total'),
        const SizedBox(height: 10),
        if (_friends.isEmpty)
          _EmptyPanel(
            icon: Iconsax.user_add,
            title: 'Your friend list is ready',
            body:
                'Search by username or email to add your first practice partner.',
            actionLabel: 'Add friend',
            onAction: _showAddFriendSheet,
          )
        else
          SizedBox(
            height: 184,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _friends.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => _FriendCard(
                friend: _friends[index],
                onChallenge: () => _showChallengeSheet(_friends[index]),
              ),
            ),
          ),
        const SizedBox(height: 22),
        _SectionTitle(
          title: 'Friend activity',
          action: '${_activity.length} recent',
        ),
        const SizedBox(height: 10),
        if (_activity.isEmpty)
          _EmptyPanel(
            icon: Iconsax.activity,
            title: 'Your feed is warming up',
            body:
                'When friends complete lessons or start challenges, their progress will appear here.',
          )
        else
          ..._activity.take(6).map(_buildActivityCard),
        const SizedBox(height: 22),
        _SectionTitle(
          title: 'Challenges',
          action: '${_challenges.length} total',
        ),
        const SizedBox(height: 10),
        if (_challenges.isEmpty)
          _EmptyPanel(
            icon: Iconsax.cup,
            title: 'No challenges yet',
            body:
                'Challenge a friend to an XP sprint and make practice feel alive.',
            actionLabel: _friends.isEmpty ? null : 'Create challenge',
            onAction: _friends.isEmpty
                ? null
                : () => _showChallengeSheet(_friends.first),
          )
        else
          ..._challenges.take(5).map(_buildChallengeCard),
        const SizedBox(height: 22),
        _SectionTitle(title: 'Chat rooms'),
        const SizedBox(height: 10),
        if (_chatRooms.isEmpty)
          const _EmptyPanel(
            icon: Iconsax.message,
            title: 'No chat rooms yet',
            body: 'Public learning communities will appear here.',
          )
        else
          ..._chatRooms.map(_buildRoomTile),
      ],
    );
  }

  Widget _buildRequestCard(FriendRequest request) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Surface(
        child: Row(
          children: [
            _Avatar(
              name: request.user.displayName,
              color: FluentianColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                  Text(
                    request.isIncoming
                        ? 'wants to practice with you'
                        : 'request sent to @${request.user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (request.isIncoming) ...[
              _TinyAction(
                icon: Iconsax.tick_circle,
                color: FluentianColors.success,
                onTap: () => _acceptRequest(request),
              ),
              const SizedBox(width: 8),
            ],
            _TinyAction(
              icon: request.isIncoming ? Iconsax.close_circle : Iconsax.trash,
              color: FluentianColors.error,
              onTap: () => _declineRequest(request),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(FriendActivity activity) {
    final style = _activityStyle(activity.activityKind);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Surface(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _Avatar(name: activity.actor.displayName, color: style.color),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: FluentianColors.border),
                    ),
                    child: Icon(style.icon, size: 13, color: style.color),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.25,
                        color: FluentianColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: activity.actor.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        TextSpan(text: ' ${activity.title}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _LevelBadge(level: activity.actor.currentLevel),
                      const SizedBox(width: 8),
                      Text(
                        _relativeTime(activity.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(FriendChallenge challenge) {
    final active = challenge.status == 'active';
    final pending = challenge.status == 'pending';
    final canRespond = pending && challenge.direction == 'incoming';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: FluentianColors.accentTint,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Iconsax.cup, color: FluentianColors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${challenge.status.toUpperCase()} · ${challenge.durationDays} days',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: active
                              ? FluentianColors.success
                              : FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canRespond) ...[
                  _TinyAction(
                    icon: Iconsax.tick_circle,
                    color: FluentianColors.success,
                    onTap: () => _updateChallenge(challenge, 'active'),
                  ),
                  const SizedBox(width: 8),
                  _TinyAction(
                    icon: Iconsax.close_circle,
                    color: FluentianColors.error,
                    onTap: () => _updateChallenge(challenge, 'declined'),
                  ),
                ],
                if (pending && !canRespond)
                  Text(
                    'Sent',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _ProgressLine(
              label: 'You',
              value: challenge.myProgress,
              target: challenge.targetValue,
              progress: challenge.myRatio,
              color: FluentianColors.primary,
            ),
            const SizedBox(height: 10),
            _ProgressLine(
              label: 'Friend',
              value: challenge.friendProgress,
              target: challenge.targetValue,
              progress: challenge.friendRatio,
              color: FluentianColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnershipCard(AccountabilityPartnership item) {
    final unit = item.goalKind == 'xp' ? 'XP' : 'lessons';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: FluentianColors.primary.withValues(alpha: .12),
        ),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: FluentianColors.headerGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Iconsax.people, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.partner.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      item.status == 'pending'
                          ? (item.direction == 'incoming'
                                ? 'Invited you to team up'
                                : 'Invitation waiting')
                          : '${item.durationDays}-day shared goal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: item.status == 'active'
                      ? const Color(0xFFEAF8F0)
                      : FluentianColors.primaryTint,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: item.status == 'active'
                        ? FluentianColors.success
                        : FluentianColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (item.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '“${item.message}”',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: FluentianColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (item.status == 'active') ...[
            _PartnerProgress(
              name: 'You',
              value: item.myProgress,
              target: item.targetValue,
              unit: unit,
              ratio: item.myRatio,
            ),
            const SizedBox(height: 10),
            _PartnerProgress(
              name: item.partner.displayName,
              value: item.partnerProgress,
              target: item.targetValue,
              unit: unit,
              ratio: item.partnerRatio,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _updatePartnership(item, 'ended'),
                child: const Text('End partnership'),
              ),
            ),
          ] else if (item.direction == 'incoming')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updatePartnership(item, 'declined'),
                    child: const Text('Not now'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updatePartnership(item, 'active'),
                    child: const Text('Team up'),
                  ),
                ),
              ],
            )
          else
            Text(
              'Goal: ${item.targetValue} $unit in ${item.durationDays} days',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FluentianColors.primaryDark,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _updatePartnership(
    AccountabilityPartnership item,
    String status,
  ) async {
    await _api.updatePartnership(item.id, status);
    await _loadSocialGraph();
  }

  Future<void> _showPartnerSheet() async {
    if (_friends.isEmpty) return;
    FriendSummary selected = _friends.first;
    String kind = 'lessons';
    int target = 5, days = 7;
    final messageController = TextEditingController();
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
                  'Choose your accountability partner',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'You both opt in and work toward the same goal.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FluentianColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<FriendSummary>(
                  initialValue: selected,
                  decoration: const InputDecoration(
                    labelText: 'Partner',
                    prefixIcon: Icon(Iconsax.people),
                    border: OutlineInputBorder(),
                  ),
                  items: _friends
                      .map(
                        (friend) => DropdownMenuItem(
                          value: friend,
                          child: Text(friend.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setSheetState(() => selected = value);
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceChip(
                        label: 'Lessons',
                        selected: kind == 'lessons',
                        onTap: () => setSheetState(() {
                          kind = 'lessons';
                          target = 5;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ChoiceChip(
                        label: 'XP',
                        selected: kind == 'xp',
                        onTap: () => setSheetState(() {
                          kind = 'xp';
                          target = 250;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StepperRow(
                  label: kind == 'xp' ? 'Target XP each' : 'Lessons each',
                  value: target,
                  step: kind == 'xp' ? 50 : 1,
                  min: 1,
                  onChanged: (value) => setSheetState(() => target = value),
                ),
                const SizedBox(height: 10),
                _StepperRow(
                  label: 'Duration (days)',
                  value: days,
                  step: 1,
                  min: 1,
                  onChanged: (value) =>
                      setSheetState(() => days = value.clamp(1, 90)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: messageController,
                  maxLength: 280,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Encouragement (optional)',
                    hintText: 'Let’s stay consistent this week!',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _api.createPartnership(
                        partnerId: selected.id,
                        goalKind: kind,
                        targetValue: target,
                        durationDays: days,
                        message: messageController.text,
                      );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      await _loadSocialGraph();
                    },
                    icon: const Icon(Iconsax.send_1),
                    label: const Text('Send invitation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    messageController.dispose();
  }

  Widget _buildRoomTile(ChatRoomModel room) {
    final isLevelRoom = room.roomKind == 'level_based';
    final color = isLevelRoom ? FluentianColors.primary : FluentianColors.info;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ChatDetailScreen(roomId: room.id, title: room.title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: _Surface(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isLevelRoom ? Iconsax.teacher : Iconsax.people,
                  size: 21,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    Text(
                      isLevelRoom
                          ? 'Level community · Tap to join the conversation'
                          : 'Public community · Tap to join the conversation',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _TinyAction(
                icon: Iconsax.call,
                color: FluentianColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(topic: room.title),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddFriendSheet() async {
    _searchController.clear();
    List<FriendSummary> results = const [];
    var searching = false;
    var hasSearched = false;
    String? message;
    final sendingRequests = <String>{};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> search() async {
            final query = _searchController.text.trim();
            if (query.length < 2) return;
            setSheetState(() {
              searching = true;
              hasSearched = true;
              message = null;
            });
            try {
              final found = await _api.searchUsers(query);
              setSheetState(() {
                results = found;
                searching = false;
              });
            } catch (e) {
              setSheetState(() {
                searching = false;
                message = e is ApiException ? e.userMessage : e.toString();
              });
            }
          }

          Future<void> add(FriendSummary user) async {
            setSheetState(() {
              sendingRequests.add(user.id);
              message = null;
            });
            try {
              await _api.sendFriendRequest(user.username);
              setSheetState(() {
                sendingRequests.remove(user.id);
                results = results.where((item) => item.id != user.id).toList();
                message = 'Request sent to ${user.displayName}.';
              });
              await _loadSocialGraph();
            } catch (e) {
              setSheetState(() {
                sendingRequests.remove(user.id);
                message = e is ApiException ? e.userMessage : e.toString();
              });
            }
          }

          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: FractionallySizedBox(
              heightFactor: 0.78,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: FluentianColors.border,
                          borderRadius: BorderRadius.circular(999),
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
                            color: FluentianColors.primaryTint,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Iconsax.user_search,
                            color: FluentianColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find a learning partner',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: FluentianColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Search by username or email address',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: FluentianColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5FC),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: FluentianColors.primary.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => search(),
                        onChanged: (_) {
                          if (message != null) {
                            setSheetState(() => message = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Username or email',
                          hintStyle: GoogleFonts.inter(
                            color: FluentianColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Iconsax.search_normal_1,
                            color: FluentianColors.primary,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: IconButton.filled(
                              tooltip: 'Search',
                              onPressed: searching ? null : search,
                              style: IconButton.styleFrom(
                                backgroundColor: FluentianColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: searching
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward_rounded),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 17,
                          ),
                        ),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: FluentianColors.primaryTint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: searching
                          ? const Center(child: CircularProgressIndicator())
                          : results.isEmpty
                          ? _FriendSearchEmpty(hasSearched: hasSearched)
                          : ListView.separated(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, index) {
                                final user = results[index];
                                final sending = sendingRequests.contains(
                                  user.id,
                                );
                                return _FriendSearchResult(
                                  user: user,
                                  sending: sending,
                                  onAdd: () => add(user),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showChallengeSheet(FriendSummary friend) async {
    var target = 100;
    var duration = 7;
    String kind = 'xp';
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Challenge ${friend.displayName}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _ChoiceChip(
                    label: 'XP sprint',
                    selected: kind == 'xp',
                    onTap: () => setSheetState(() => kind = 'xp'),
                  ),
                  const SizedBox(width: 10),
                  _ChoiceChip(
                    label: 'Lessons',
                    selected: kind == 'lessons',
                    onTap: () => setSheetState(() {
                      kind = 'lessons';
                      target = target > 20 ? 5 : target;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StepperRow(
                label: kind == 'xp' ? 'Target XP' : 'Target lessons',
                value: target,
                step: kind == 'xp' ? 50 : 1,
                min: 1,
                onChanged: (value) => setSheetState(() => target = value),
              ),
              const SizedBox(height: 12),
              _StepperRow(
                label: 'Days',
                value: duration,
                step: 1,
                min: 1,
                onChanged: (value) => setSheetState(() => duration = value),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.cup),
                  label: const Text('Send challenge'),
                  onPressed: () async {
                    try {
                      await _api.createChallenge(
                        friendId: friend.id,
                        challengeKind: kind,
                        targetValue: target,
                        durationDays: duration,
                      );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      await _loadSocialGraph();
                    } catch (e) {
                      if (!sheetContext.mounted) return;
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            e is ApiException ? e.userMessage : e.toString(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptRequest(FriendRequest request) async {
    await _api.acceptFriendRequest(request.id);
    await _loadSocialGraph();
  }

  Future<void> _declineRequest(FriendRequest request) async {
    await _api.declineOrCancelFriendRequest(request.id);
    await _loadSocialGraph();
  }

  Future<void> _updateChallenge(
    FriendChallenge challenge,
    String status,
  ) async {
    await _api.updateChallengeStatus(challengeId: challenge.id, status: status);
    await _loadSocialGraph();
  }

  _ActivityStyle _activityStyle(String kind) {
    switch (kind) {
      case 'lesson_completed':
        return const _ActivityStyle(
          Iconsax.tick_circle,
          FluentianColors.success,
        );
      case 'challenge_created':
        return const _ActivityStyle(Iconsax.cup, FluentianColors.accent);
      case 'friend_added':
        return const _ActivityStyle(Iconsax.people, FluentianColors.info);
      default:
        return const _ActivityStyle(Iconsax.activity, FluentianColors.primary);
    }
  }

  String _relativeTime(DateTime value) {
    final elapsed = DateTime.now().difference(value.toLocal());
    if (elapsed.inMinutes < 1) return 'now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
    if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
    if (elapsed.inDays < 7) return '${elapsed.inDays}d ago';
    return '${value.month}/${value.day}/${value.year}';
  }
}

class _FriendSearchEmpty extends StatelessWidget {
  final bool hasSearched;

  const _FriendSearchEmpty({required this.hasSearched});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: FluentianColors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearched ? Iconsax.user_remove : Iconsax.people,
                size: 32,
                color: FluentianColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasSearched ? 'No learners found' : 'Build your French circle',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hasSearched
                  ? 'Check the spelling or try another username or email.'
                  : 'Search for a learner, connect, and motivate each other as you progress.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.45,
                color: FluentianColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendSearchResult extends StatelessWidget {
  final FriendSummary user;
  final bool sending;
  final VoidCallback onAdd;

  const _FriendSearchResult({
    required this.user,
    required this.sending,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final name = user.displayName.trim().isEmpty
        ? user.username
        : user.displayName.trim();
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.055)),
        boxShadow: [
          BoxShadow(
            color: FluentianColors.primary.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [FluentianColors.primary, Color(0xFF8A5CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '@${user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FluentianColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _FriendStat(label: user.currentLevel.toUpperCase()),
                    _FriendStat(label: '${user.xpTotal} XP'),
                    _FriendStat(label: '${user.streakDays} day streak'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 43,
            height: 43,
            child: IconButton.filled(
              tooltip: 'Add ${user.displayName}',
              onPressed: sending ? null : onAdd,
              style: IconButton.styleFrom(
                backgroundColor: FluentianColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: FluentianColors.primaryTint,
              ),
              icon: sending
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FluentianColors.primary,
                      ),
                    )
                  : const Icon(Iconsax.user_add, size: 19),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendStat extends StatelessWidget {
  final String label;

  const _FriendStat({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: FluentianColors.primaryDark,
        ),
      ),
    );
  }
}

class _ActivityStyle {
  final IconData icon;
  final Color color;

  const _ActivityStyle(this.icon, this.color);
}

class _PartnerProgress extends StatelessWidget {
  final String name, unit;
  final int value, target;
  final double ratio;
  const _PartnerProgress({
    required this.name,
    required this.unit,
    required this.value,
    required this.target,
    required this.ratio,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$value / $target $unit',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textSecondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: ratio,
          minHeight: 7,
          backgroundColor: FluentianColors.primaryTint,
          color: FluentianColors.primary,
        ),
      ),
    ],
  );
}

class _FriendCard extends StatelessWidget {
  final FriendSummary friend;
  final VoidCallback onChallenge;

  const _FriendCard({required this.friend, required this.onChallenge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 232,
      child: _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(
                  name: friend.displayName,
                  color: FluentianColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      Text(
                        '@${friend.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _LevelBadge(level: friend.currentLevel),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _FriendMetric(label: 'XP', value: '${friend.xpTotal}'),
                ),
                Expanded(
                  child: _FriendMetric(
                    label: 'Streak',
                    value: '${friend.streakDays}d',
                  ),
                ),
                Expanded(
                  child: _FriendMetric(
                    label: 'Lessons',
                    value: '${friend.lessonsCompleted}',
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 38,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onChallenge,
                icon: const Icon(Iconsax.cup, size: 17),
                label: const Text('Challenge'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: FluentianColors.primaryTint,
                  foregroundColor: FluentianColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  final Widget child;

  const _Surface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: FluentianColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: FluentianColors.primary,
            ),
          ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final Color color;

  const _Avatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'F' : name.trim()[0].toUpperCase();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconButton({
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: FluentianColors.primaryTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: FluentianColors.primary, size: 21),
        ),
      ),
    );
  }
}

class _TinyAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TinyAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: FluentianColors.primary,
        ),
      ),
    );
  }
}

class _FriendMetric extends StatelessWidget {
  final String label;
  final String value;

  const _FriendMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: FluentianColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: FluentianColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final double progress;
  final Color color;

  const _ProgressLine({
    required this.label,
    required this.value,
    required this.target,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: FluentianColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '$value / $target',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: FluentianColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        children: [
          Icon(icon, color: FluentianColors.primary, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.35,
              color: FluentianColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _EmptyPanel(
      icon: Iconsax.warning_2,
      title: 'Could not load social',
      body: message,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

class _SocialLoading extends StatelessWidget {
  const _SocialLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: index == 0 ? 120 : 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? FluentianColors.primary
              : FluentianColors.primaryTint,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: selected ? Colors.white : FluentianColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int step;
  final int min;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.step,
    required this.min,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: FluentianColors.textPrimary,
            ),
          ),
        ),
        _TinyStepperButton(
          icon: Iconsax.minus,
          onTap: () => onChanged((value - step).clamp(min, 9999)),
        ),
        SizedBox(
          width: 70,
          child: Center(
            child: Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: FluentianColors.textPrimary,
              ),
            ),
          ),
        ),
        _TinyStepperButton(
          icon: Iconsax.add,
          onTap: () => onChanged((value + step).clamp(min, 9999)),
        ),
      ],
    );
  }
}

class _TinyStepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TinyStepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: FluentianColors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: FluentianColors.primary, size: 18),
      ),
    );
  }
}
