import 'package:flutter_test/flutter_test.dart';
import 'package:fluentian/models/progress_model.dart';
import 'package:fluentian/core/constants.dart';

LessonProgressModel progress({
  required String lessonId,
  required bool completed,
  required DateTime? completedAt,
}) => LessonProgressModel(
  id: lessonId,
  userId: 'learner',
  lessonId: lessonId,
  masteryScore: completed ? 1 : 0,
  completed: completed,
  completedAt: completedAt,
  createdAt: completedAt ?? DateTime(2026, 8, 3),
);

void main() {
  test('daily challenge follows the saved study-time goal', () {
    expect(lessonsForDailyGoalMinutes(5), 1);
    expect(lessonsForDailyGoalMinutes(10), 2);
    expect(lessonsForDailyGoalMinutes(15), 3);
    expect(lessonsForDailyGoalMinutes(40), 8);
  });

  test('daily challenge counts only lessons completed on the selected day', () {
    final today = DateTime(2026, 8, 3, 12);
    final items = [
      progress(
        lessonId: 'today-1',
        completed: true,
        completedAt: DateTime(2026, 8, 3, 8),
      ),
      progress(
        lessonId: 'today-2',
        completed: true,
        completedAt: DateTime(2026, 8, 3, 20),
      ),
      progress(
        lessonId: 'yesterday',
        completed: true,
        completedAt: DateTime(2026, 8, 2, 23, 59),
      ),
      progress(lessonId: 'incomplete', completed: false, completedAt: today),
      progress(lessonId: 'missing-date', completed: true, completedAt: null),
    ];

    expect(countCompletedLessonsOnDay(items, today), 2);
    expect(countCompletedLessonsOnDay(items, DateTime(2026, 8, 2)), 1);
  });
}
