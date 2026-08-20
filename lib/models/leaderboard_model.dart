class LeaderboardEntryModel {
  final int? rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String currentLevel;
  final int weeklyXp;
  final bool isCurrentUser;

  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.currentLevel,
    required this.weeklyXp,
    required this.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryModel(
        rank: (json['rank'] as num?)?.toInt(),
        userId: json['user_id']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? 'Learner',
        avatarUrl: json['avatar_url']?.toString(),
        currentLevel: json['current_level']?.toString() ?? 'A0',
        weeklyXp: (json['weekly_xp'] as num?)?.toInt() ?? 0,
        isCurrentUser: json['is_current_user'] as bool? ?? false,
      );
}

class LeaderboardWinnerModel {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int bonusXp;

  const LeaderboardWinnerModel({
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.bonusXp,
  });

  factory LeaderboardWinnerModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardWinnerModel(
        userId: json['user_id']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? 'Learner',
        avatarUrl: json['avatar_url']?.toString(),
        bonusXp: (json['bonus_xp'] as num?)?.toInt() ?? 0,
      );
}

class WeeklyLeaderboardModel {
  final DateTime periodStart;
  final DateTime periodEnd;
  final Duration remaining;
  final int rewardXp;
  final int participantCount;
  final List<LeaderboardEntryModel> entries;
  final LeaderboardEntryModel currentUser;
  final LeaderboardWinnerModel? previousWinner;

  const WeeklyLeaderboardModel({
    required this.periodStart,
    required this.periodEnd,
    required this.remaining,
    required this.rewardXp,
    required this.participantCount,
    required this.entries,
    required this.currentUser,
    required this.previousWinner,
  });

  factory WeeklyLeaderboardModel.fromJson(Map<String, dynamic> json) {
    final previous = json['previous_winner'];
    return WeeklyLeaderboardModel(
      periodStart: DateTime.parse(json['period_start'].toString()),
      periodEnd: DateTime.parse(json['period_end'].toString()),
      remaining: Duration(
        seconds: (json['seconds_remaining'] as num?)?.toInt() ?? 0,
      ),
      rewardXp: (json['reward_xp'] as num?)?.toInt() ?? 100,
      participantCount: (json['participant_count'] as num?)?.toInt() ?? 0,
      entries: (json['entries'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                LeaderboardEntryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      currentUser: LeaderboardEntryModel.fromJson(
        json['current_user'] as Map<String, dynamic>,
      ),
      previousWinner: previous is Map<String, dynamic>
          ? LeaderboardWinnerModel.fromJson(previous)
          : null,
    );
  }
}
