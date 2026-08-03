import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';
import '../services/content_api.dart';
import '../services/progress_api.dart';
import '../services/api_client.dart';

enum ContentStatus { idle, loading, loaded, error }

/// Holds course/unit/lesson data and lesson progress for the whole session.
class ContentProvider extends ChangeNotifier {
  ContentStatus _status = ContentStatus.idle;
  String? _error;
  List<CourseModel> _courses = [];
  final Map<String, LessonDetailModel> _lessonCache = {};
  final Map<String, LessonProgressModel> _progressByLesson = {};
  final Set<String> _enrolledCourseIds = {};
  UserStatsModel? _stats;

  ContentStatus get status => _status;
  String? get error => _error;
  List<CourseModel> get courses => _courses;
  UserStatsModel? get stats => _stats;
  Set<String> get enrolledCourseIds => Set.unmodifiable(_enrolledCourseIds);
  bool get isLoading => _status == ContentStatus.loading;

  final _contentApi = ContentApi.instance;
  final _progressApi = ProgressApi.instance;

  /// Fetch all courses + user stats in one go. Called on home screen load.
  Future<void> loadHomeData() async {
    _status = ContentStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _courses = await _contentApi.getCourses();

      try {
        _stats = await _progressApi.getMyStats();
      } catch (e) {
        if (kDebugMode) debugPrint('loadHomeData stats error: $e');
        _stats = const UserStatsModel(
          totalXp: 0,
          streakDays: 0,
          lessonsCompleted: 0,
          unitsCompleted: 0,
          hearts: 5,
          currentLevel: 'A0',
          weeklyXp: 0,
        );
      }

      List<EnrollmentModel> enrollments = const [];
      try {
        enrollments = await _progressApi.getMyEnrollments();
      } catch (e) {
        if (kDebugMode) debugPrint('loadHomeData enrollments error: $e');
      }

      _enrolledCourseIds
        ..clear()
        ..addAll(enrollments.where((e) => e.isActive).map((e) => e.courseId));
      _status = ContentStatus.loaded;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _status = ContentStatus.error;
    } on NetworkException catch (e) {
      _error = e.message;
      _status = ContentStatus.error;
    } catch (e) {
      _error = 'Failed to load content.';
      _status = ContentStatus.error;
      if (kDebugMode) debugPrint('ContentProvider.loadHomeData error: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Fetch full lesson detail (cached by lessonId).
  Future<LessonDetailModel?> getLessonDetail(String lessonId) async {
    if (_lessonCache.containsKey(lessonId)) return _lessonCache[lessonId];
    try {
      final detail = await _contentApi.getLessonDetail(lessonId);
      _lessonCache[lessonId] = detail;
      notifyListeners();
      return detail;
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('getLessonDetail error: ${e.message}');
      return null;
    } on NetworkException {
      return null;
    }
  }

  /// Fetch and cache lesson progress for a given list of lesson IDs.
  Future<void> loadLessonProgress() async {
    try {
      final progress = await _progressApi.getMyLessonProgress();
      _progressByLesson.clear();
      for (final p in progress) {
        _progressByLesson[p.lessonId] = p;
      }
      notifyListeners();
    } catch (_) {
      // Non-fatal: progress can be stale
    }
  }

  /// Check if a specific lesson is completed.
  bool isLessonCompleted(String lessonId) =>
      _progressByLesson[lessonId]?.completed ?? false;

  /// Unique lessons first completed on the learner's current local calendar day.
  int get lessonsCompletedToday {
    return countCompletedLessonsOnDay(_progressByLesson.values, DateTime.now());
  }

  bool isCourseEnrolled(String courseId) =>
      _enrolledCourseIds.contains(courseId);

  Future<bool> enrollInCourse(String courseId) async {
    try {
      final enrollment = await _progressApi.enrollInCourse(courseId);
      if (enrollment.isActive) {
        _enrolledCourseIds.add(enrollment.courseId);
      }
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        _enrolledCourseIds.add(courseId);
        notifyListeners();
        return true;
      }
      _error = e.userMessage;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('enrollInCourse error: $e');
      _error = 'Could not enroll in this course.';
      notifyListeners();
      return false;
    }
  }

  /// Get mastery score for a lesson (0.0–1.0).
  double getLessonMastery(String lessonId) =>
      _progressByLesson[lessonId]?.masteryScore ?? 0.0;

  /// Determine lesson unlock state from progress.
  /// A lesson is unlocked if it's the first, or the previous is completed.
  bool isLessonUnlocked(List<LessonModel> lessons, int index) {
    if (index == 0) return true;
    final prevLesson = lessons[index - 1];
    return isLessonCompleted(prevLesson.id);
  }

  /// Get up to [count] next incomplete lessons across all courses/units.
  List<LessonModel> getIncompleteLessons(int count) {
    final incomplete = <LessonModel>[];
    for (final course in _courses) {
      for (final unit in course.units) {
        for (int i = 0; i < unit.lessons.length; i++) {
          final lesson = unit.lessons[i];
          if (!isLessonCompleted(lesson.id) &&
              isLessonUnlocked(unit.lessons, i)) {
            incomplete.add(lesson);
            if (incomplete.length >= count) return incomplete;
          }
        }
      }
    }
    return incomplete;
  }

  LessonModel? firstLessonByKind(String lessonKind) {
    for (final course in _courses) {
      for (final unit in course.units) {
        for (final lesson in unit.lessons) {
          if (lesson.lessonKind == lessonKind) return lesson;
        }
      }
    }
    return null;
  }

  /// Submit lesson completion and refresh stats.
  Future<CompleteLessonResult?> completeLesson({
    required String lessonId,
    required double score,
    required List<AnswerPayload> answers,
    required int timeSeconds,
    int heartsSpent = 0,
  }) async {
    try {
      final existingProgress = _progressByLesson[lessonId];
      final result = await _progressApi.completeLesson(
        lessonId: lessonId,
        score: score,
        answers: answers,
        timeSeconds: timeSeconds,
        heartsSpent: heartsSpent,
      );
      // Mark lesson as completed locally immediately
      _progressByLesson[lessonId] = LessonProgressModel(
        id: '',
        userId: '',
        lessonId: lessonId,
        masteryScore: score,
        completed: true,
        completedAt: existingProgress?.completedAt ?? DateTime.now(),
        createdAt: DateTime.now(),
      );
      _lessonCache.remove(lessonId);
      // Refresh global stats
      try {
        _stats = await _progressApi.getMyStats();
      } catch (e) {
        if (kDebugMode) debugPrint('refresh stats after completion error: $e');
      }
      notifyListeners();
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('completeLesson error: $e');
      return null;
    }
  }

  /// Refresh just the user stats (called after XP events).
  Future<void> refreshStats() async {
    try {
      _stats = await _progressApi.getMyStats();
      notifyListeners();
    } catch (_) {}
  }

  /// Get due SRS questions
  Future<List<QuestionModel>> getDueSrsQuestions() async {
    try {
      return await _contentApi.getDueSrsQuestions();
    } catch (e) {
      if (kDebugMode) debugPrint('getDueSrsQuestions error: $e');
      return [];
    }
  }

  /// Submit SRS review session
  Future<Map<String, dynamic>?> completeSrsReview({
    required List<AnswerPayload> answers,
    required int timeSeconds,
  }) async {
    try {
      final payload = answers
          .map(
            (a) => {
              'question_id': a.questionId,
              'answer': a.answer,
              'is_correct': a.isCorrect,
            },
          )
          .toList();
      final result = await _contentApi.completeSrsReview(payload, timeSeconds);

      // Refresh global stats after SRS
      try {
        _stats = await _progressApi.getMyStats();
      } catch (e) {
        if (kDebugMode) debugPrint('refresh stats after SRS error: $e');
      }
      notifyListeners();
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('completeSrsReview error: $e');
      return null;
    }
  }
}
