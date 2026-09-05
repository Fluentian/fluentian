import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../models/leaderboard_model.dart';
import '../services/api_client.dart';
import '../services/progress_api.dart';
import '../widgets/user_avatar.dart';

class LeaderboardScreen extends StatefulWidget {
  final Future<WeeklyLeaderboardModel> Function()? loadLeaderboard;

  const LeaderboardScreen({super.key, this.loadLeaderboard});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _api = ProgressApi.instance;
  WeeklyLeaderboardModel? _board;
  String? _error;
  bool _loading = true;
  Duration _remaining = Duration.zero;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _load();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _remaining == Duration.zero) return;
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final board =
          await (widget.loadLeaderboard?.call() ?? _api.getWeeklyLeaderboard());
      if (!mounted) return;
      setState(() {
        _board = board;
        _remaining = board.remaining;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is ApiException ? error.userMessage : error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _LeaderboardAppBar(onRefresh: () => _load(showSpinner: false)),
            Expanded(
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                child: _loading
                    ? const _LeaderboardLoading(key: ValueKey('loading'))
                    : _error != null
                    ? _LeaderboardError(
                        key: const ValueKey('error'),
                        message: _error!,
                        onRetry: _load,
                      )
                    : _buildBoard(_board!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoard(WeeklyLeaderboardModel board) {
    final ranked = board.entries;
    final podium = ranked.take(3).toList(growable: false);
    final remaining = ranked.skip(3).toList(growable: false);
    return RefreshIndicator(
      onRefresh: () => _load(showSpinner: false),
      color: FluentianColors.secondary,
      child: ListView(
        key: const ValueKey('board'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _LeagueHero(
            remaining: _remaining,
            rewardXp: board.rewardXp,
            participantCount: board.participantCount,
          ),
          if (board.previousWinner case final winner?) ...[
            const SizedBox(height: 12),
            _PreviousWinnerBanner(winner: winner),
          ],
          const SizedBox(height: 22),
          if (podium.isEmpty)
            _EmptyLeague(rewardXp: board.rewardXp)
          else ...[
            _Podium(entries: podium),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 22),
              const _SectionLabel('THE CHASING PACK'),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: FluentianColors.border),
                  boxShadow: [FluentianShadows.subtle],
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < remaining.length; i++) ...[
                      _RankRow(entry: remaining[i]),
                      if (i != remaining.length - 1)
                        const Divider(height: 1, indent: 66, endIndent: 16),
                    ],
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 22),
          const _SectionLabel('YOUR PLACE'),
          const SizedBox(height: 10),
          _CurrentLearnerCard(entry: board.currentUser),
          const SizedBox(height: 12),
          LText(
            'Only XP earned from lessons and reviews counts here. The winner bonus is added to total XP after the league closes, but not to the next competition.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardAppBar extends StatelessWidget {
  final VoidCallback onRefresh;

  const _LeaderboardAppBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        Expanded(
          child: LText(
            'Weekly league',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Refresh leaderboard',
          onPressed: onRefresh,
          icon: const Icon(Iconsax.refresh),
        ),
      ],
    ),
  );
}

class _LeagueHero extends StatelessWidget {
  final Duration remaining;
  final int rewardXp;
  final int participantCount;

  const _LeagueHero({
    required this.remaining,
    required this.rewardXp,
    required this.participantCount,
  });

  String get _timeLabel {
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    if (days > 0) return '${days}d ${hours}h left';
    if (hours > 0) return '${hours}h ${minutes}m left';
    return '${minutes}m left';
  }

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: FluentianColors.primary,
      boxShadow: [
        FluentianShadows.subtle,
      ],
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: LText(
                  _timeLabel.toUpperCase(),
                  style: FluentianTheme.label(size: 10, color: FluentianColors.accent),
                ),
              ),
              const SizedBox(height: 14),
              LText(
                'Learn your way to first.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'The top learner earns +$rewardXp bonus XP when this week closes.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.onInkMuted,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Iconsax.people5, size: 16, color: Colors.white),
                  const SizedBox(width: 7),
                  LText(
                    '$participantCount active learner${participantCount == 1 ? '' : 's'} this week',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Podium extends StatelessWidget {
  final List<LeaderboardEntryModel> entries;

  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    LeaderboardEntryModel? at(int rank) {
      for (final entry in entries) {
        if (entry.rank == rank) return entry;
      }
      return null;
    }

    return Semantics(
      label: 'Top three learners',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _PodiumPlace(entry: at(2), rank: 2, height: 155)),
          const SizedBox(width: 7),
          Expanded(child: _PodiumPlace(entry: at(1), rank: 1, height: 180)),
          const SizedBox(width: 7),
          Expanded(child: _PodiumPlace(entry: at(3), rank: 3, height: 150)),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  final LeaderboardEntryModel? entry;
  final int rank;
  final double height;

  const _PodiumPlace({
    required this.entry,
    required this.rank,
    required this.height,
  });

  /// Gold, silver, bronze. Kept as literal metals rather than mapped onto the
  /// semantic palette -- these three read as a podium precisely because they
  /// are the medal colours, and rank is also carried by position and by the
  /// numeral, so nothing here depends on telling them apart by hue.
  /// Gold, silver, bronze. Kept as literal metals rather than mapped onto the
  /// semantic palette -- these three read as a podium precisely because they
  /// are the medal colours. The originals (#7C93A8, #B77946) sat at 2.6-2.9:1
  /// on paper; these clear 4.5:1, and they now only carry the ring and the
  /// 3px rule. The rank numeral itself is ink, because a number is data and
  /// should not be the thing whose legibility depends on a metal.
  Color get _color => switch (rank) {
    1 => FluentianColors.warning, // 5.49:1 on paper
    2 => const Color(0xFF54677A), // 4.74:1
    _ => const Color(0xFF8A5730), // 4.90:1
  };

  @override
  Widget build(BuildContext context) {
    if (entry == null) return SizedBox(height: height);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _LearnerAvatar(
          entry: entry!,
          size: rank == 1 ? 58 : 48,
          ringColor: _color,
        ),
        const SizedBox(height: 7),
        LText(
          entry!.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: height - (rank == 1 ? 82 : 72),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 8),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: .13),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            border: Border(top: BorderSide(color: _color, width: 3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$rank',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: rank == 1 ? 27 : 22,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: FluentianColors.textPrimary,
                ),
              ),
              LText(
                '${entry!.weeklyXp} XP',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntryModel entry;

  const _RankRow({required this.entry});

  @override
  Widget build(BuildContext context) => Container(
    color: entry.isCurrentUser
        ? FluentianColors.secondaryTint
        : Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        SizedBox(
          width: 28,
          child: LText(
            '${entry.rank ?? '—'}',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textSecondary,
            ),
          ),
        ),
        _LearnerAvatar(entry: entry, size: 38),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                entry.isCurrentUser
                    ? '${entry.displayName} · You'
                    : entry.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.textPrimary,
                ),
              ),
              LText(
                entry.currentLevel,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        LText(
          '${entry.weeklyXp} XP',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: FluentianColors.secondary,
          ),
        ),
      ],
    ),
  );
}

class _CurrentLearnerCard extends StatelessWidget {
  final LeaderboardEntryModel entry;

  const _CurrentLearnerCard({required this.entry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: FluentianColors.primaryDark,
      borderRadius: BorderRadius.circular(0),
      boxShadow: [FluentianShadows.subtle],
    ),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(0),
          ),
          child: LText(
            entry.rank == null ? '—' : '#${entry.rank}',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: FluentianColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                entry.rank == null
                    ? 'Earn XP to join the league'
                    : entry.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              LText(
                entry.rank == null
                    ? 'Complete a lesson or review'
                    : '${entry.currentLevel} this week',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.onInkMuted,
                ),
              ),
            ],
          ),
        ),
        LText(
          '${entry.weeklyXp} XP',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _LearnerAvatar extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final double size;
  final Color? ringColor;

  const _LearnerAvatar({
    required this.entry,
    required this.size,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      avatarUrl: entry.avatarUrl,
      name: entry.displayName,
      size: size,
      borderColor: ringColor,
      borderWidth: ringColor != null ? 2.5 : 1.5,
    );
  }
}

class _PreviousWinnerBanner extends StatelessWidget {
  final LeaderboardWinnerModel winner;

  const _PreviousWinnerBanner({required this.winner});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: FluentianColors.warningTint,
      borderRadius: BorderRadius.circular(0),
      border: Border.all(color: FluentianColors.warning.withValues(alpha: .3)),
    ),
    child: Row(
      children: [
        const Icon(
          Iconsax.medal_star5,
          color: FluentianColors.warning,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LText(
            '${winner.displayName} won last week and earned +${winner.bonusXp} XP.',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w800,
              color: FluentianColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyLeague extends StatelessWidget {
  final int rewardXp;

  const _EmptyLeague({required this.rewardXp});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(0),
      border: Border.all(color: FluentianColors.border),
    ),
    child: Column(
      children: [
        const Icon(Iconsax.cup, size: 42, color: FluentianColors.secondary),
        const SizedBox(height: 12),
        LText(
          'The league is open',
          style: GoogleFonts.ibmPlexSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        LText(
          'Be the first to earn XP this week and start the race for the +$rewardXp XP prize.',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            height: 1.4,
            color: FluentianColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => LText(
    text,
    style: FluentianTheme.label(size: 10, color: FluentianColors.textSecondary),
  );
}

class _LeaderboardLoading extends StatelessWidget {
  const _LeaderboardLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: FluentianColors.secondary),
  );
}

class _LeaderboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LeaderboardError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconsax.cloud_cross,
            size: 44,
            color: FluentianColors.textSecondary,
          ),
          const SizedBox(height: 12),
          LText(message, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton(onPressed: onRetry, child: const LText('Try again')),
        ],
      ),
    ),
  );
}
