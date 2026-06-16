/// Progress models — mirrors backend progress schemas.

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

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) =>
      LessonProgressModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        lessonId: json['lesson_id'] as String,
        masteryScore: (json['mastery_score'] as num?)?.toDouble() ?? 0.0,
        completed: json['completed'] as bool? ?? false,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
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
  final int heartsRemaining;
  final bool lessonCompleted;
  final bool unitCompleted;

  const CompleteLessonResult({
    required this.xpEarned,
    required this.newXpTotal,
    required this.streakDays,
    required this.heartsRemaining,
    required this.lessonCompleted,
    required this.unitCompleted,
  });

  factory CompleteLessonResult.fromJson(Map<String, dynamic> json) =>
      CompleteLessonResult(
        xpEarned: json['xp_earned'] as int? ?? 0,
        newXpTotal: json['new_xp_total'] as int? ?? 0,
        streakDays: json['streak_days'] as int? ?? 0,
        heartsRemaining: json['hearts_remaining'] as int? ?? 5,
        lessonCompleted: json['lesson_completed'] as bool? ?? false,
        unitCompleted: json['unit_completed'] as bool? ?? false,
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
