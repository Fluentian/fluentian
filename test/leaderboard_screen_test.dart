import 'package:fluentian/models/leaderboard_model.dart';
import 'package:fluentian/screens/leaderboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders podium, reward, and the current learner position', (
    tester,
  ) async {
    const entries = [
      LeaderboardEntryModel(
        rank: 1,
        userId: '1',
        displayName: 'Amina',
        avatarUrl: null,
        currentLevel: 'A2',
        weeklyXp: 240,
        isCurrentUser: false,
      ),
      LeaderboardEntryModel(
        rank: 2,
        userId: '2',
        displayName: 'Bilal',
        avatarUrl: null,
        currentLevel: 'A1',
        weeklyXp: 180,
        isCurrentUser: true,
      ),
      LeaderboardEntryModel(
        rank: 3,
        userId: '3',
        displayName: 'Hana',
        avatarUrl: null,
        currentLevel: 'B1',
        weeklyXp: 150,
        isCurrentUser: false,
      ),
      LeaderboardEntryModel(
        rank: 4,
        userId: '4',
        displayName: 'Noah',
        avatarUrl: null,
        currentLevel: 'A2',
        weeklyXp: 120,
        isCurrentUser: false,
      ),
    ];
    final board = WeeklyLeaderboardModel(
      periodStart: DateTime(2026, 8, 17),
      periodEnd: DateTime(2026, 8, 24),
      remaining: const Duration(days: 2),
      rewardXp: 100,
      participantCount: 4,
      entries: entries,
      currentUser: entries[1],
      previousWinner: const LeaderboardWinnerModel(
        userId: 'old',
        displayName: 'Sara',
        avatarUrl: null,
        bonusXp: 100,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: LeaderboardScreen(loadLeaderboard: () async => board)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Learn your way to first.'), findsOneWidget);
    expect(find.text('Amina'), findsOneWidget);
    expect(find.text('Bilal'), findsOneWidget);
    expect(find.text('Noah'), findsOneWidget);
    expect(find.textContaining('Sara won last week'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('YOUR PLACE'), 400);
    expect(find.text('#2'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
