/// Progress models — mirrors backend progress schemas.
library;

int countCompletedLessonsOnDay(
  Iterable<LessonProgressModel> progress,
  DateTime day,
) {
  final localDay = day.toLocal();
  return progress.where((item) {
    final completedAt = item.completedAt?.toLocal();
    return item.completed &&
        completedAt != null &&
        completedAt.year == localDay.year &&
        completedAt.month == localDay.month &&
        completedAt.day == localDay.day;
  }).length;
}

class LessonProgressModel {
  final String id;
  final String userId;
  final String lessonId;
  final double masteryScore;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;

  const LessonProgressModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.masteryScore,
    required this.completed,
    this.completedAt,
    required this.createdAt,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCompletedAt;
    if (json['completed_at'] != null) {
      parsedCompletedAt = DateTime.tryParse(json['completed_at'].toString());
    }

    DateTime parsedCreatedAt = DateTime.now();
    if (json['created_at'] != null) {
      parsedCreatedAt =
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return LessonProgressModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      lessonId: json['lesson_id']?.toString() ?? '',
      masteryScore:
          (json['mastery_score'] as num?)?.toDouble() ??
          (json['score'] as num?)?.toDouble() ??
          0.0,
      completed:
          json['completed'] as bool? ?? json['is_completed'] as bool? ?? false,
      completedAt: parsedCompletedAt,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'lesson_id': lessonId,
    'mastery_score': masteryScore,
    'completed': completed,
    'completed_at': completedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}

class UserStatsModel {
  final int totalXp;
  final int streakDays;
  final int lessonsCompleted;
  final int unitsCompleted;
  final int hearts;
  final String currentLevel;
  final int weeklyXp;

  const UserStatsModel({
    required this.totalXp,
    required this.streakDays,
    required this.lessonsCompleted,
    required this.unitsCompleted,
    required this.hearts,
    required this.currentLevel,
    required this.weeklyXp,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) => UserStatsModel(
    totalXp: json['total_xp'] as int? ?? 0,
    streakDays: json['streak_days'] as int? ?? 0,
    lessonsCompleted: json['lessons_completed'] as int? ?? 0,
    unitsCompleted: json['units_completed'] as int? ?? 0,
    hearts: json['hearts'] as int? ?? 5,
    currentLevel: json['current_level'] as String? ?? 'A0',
    weeklyXp: json['weekly_xp'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'total_xp': totalXp,
    'streak_days': streakDays,
    'lessons_completed': lessonsCompleted,
    'units_completed': unitsCompleted,
    'hearts': hearts,
    'current_level': currentLevel,
    'weekly_xp': weeklyXp,
  };
}

class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final bool isActive;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    required this.isActive,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        courseId: json['course_id'] as String,
        enrolledAt: DateTime.parse(json['enrolled_at'] as String),
        isActive: json['is_active'] as bool? ?? true,
      );
}

class CompleteLessonResult {
  final int xpEarned;
  final int newXpTotal;
  final int streakDays;
  final int streakFreezes;
  final bool streakFreezeEarned;
  final int heartsRemaining;
  final bool lessonCompleted;
  final bool unitCompleted;

  /// Authoritative graded score (0.0-1.0) from the server. Null when the
  /// backend predates this field. Prefer this over the client's local tally
  /// for display, since the local tally counts ungraded speaking prompts.
  final double? score;

  const CompleteLessonResult({
    required this.xpEarned,
    required this.newXpTotal,
    required this.streakDays,
    this.streakFreezes = 0,
    this.streakFreezeEarned = false,
    required this.heartsRemaining,
    required this.lessonCompleted,
    required this.unitCompleted,
    this.score,
  });

  factory CompleteLessonResult.fromJson(Map<String, dynamic> json) =>
      CompleteLessonResult(
        xpEarned: json['xp_earned'] as int? ?? 0,
        newXpTotal: json['new_xp_total'] as int? ?? 0,
        streakDays: json['streak_days'] as int? ?? 0,
        streakFreezes: json['streak_freezes'] as int? ?? 0,
        streakFreezeEarned: json['streak_freeze_earned'] as bool? ?? false,
        heartsRemaining: json['hearts_remaining'] as int? ?? 5,
        lessonCompleted: json['lesson_completed'] as bool? ?? false,
        unitCompleted: json['unit_completed'] as bool? ?? false,
        score: (json['score'] as num?)?.toDouble(),
      );
}

class AnswerPayload {
  final String questionId;
  final dynamic answer;
  final bool isCorrect;

  const AnswerPayload({
    required this.questionId,
    required this.answer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'answer': answer,
    'is_correct': isCorrect,
  };
}
