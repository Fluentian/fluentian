import 'package:flutter_test/flutter_test.dart';
import 'package:fluentian/models/leaderboard_model.dart';

void main() {
  test('parses weekly leaderboard and current learner rank', () {
    final board = WeeklyLeaderboardModel.fromJson({
      'period_start': '2026-08-17',
      'period_end': '2026-08-24',
      'seconds_remaining': 3600,
      'reward_xp': 100,
      'participant_count': 1,
      'entries': [
        {
          'rank': 1,
          'user_id': 'one',
          'display_name': 'Amina',
          'avatar_url': null,
          'current_level': 'A2',
          'weekly_xp': 240,
          'is_current_user': true,
        },
      ],
      'current_user': {
        'rank': 1,
        'user_id': 'one',
        'display_name': 'Amina',
        'avatar_url': null,
        'current_level': 'A2',
        'weekly_xp': 240,
        'is_current_user': true,
      },
      'previous_winner': {
        'user_id': 'old-winner',
        'display_name': 'Bilal',
        'avatar_url': null,
        'bonus_xp': 100,
      },
    });

    expect(board.entries.single.displayName, 'Amina');
    expect(board.currentUser.rank, 1);
    expect(board.remaining, const Duration(hours: 1));
    expect(board.participantCount, 1);
    expect(board.previousWinner?.displayName, 'Bilal');
  });
}
