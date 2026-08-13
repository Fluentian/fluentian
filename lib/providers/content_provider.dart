import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../local_db/app_database.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';
import '../services/content_api.dart';
import '../services/outbox_manager.dart';
import '../services/progress_api.dart';
import '../services/sync_manager.dart';
import '../services/api_client.dart';
import '../services/starter_curriculum_loader.dart';

enum ContentStatus { idle, loading, loaded, error }

/// Holds course/unit/lesson data and lesson progress for the whole session.
class ContentProvider extends ChangeNotifier {
  ContentStatus _status = ContentStatus.idle;
  String? _error;
  List<CourseModel> _courses = [];
  final Map<String, LessonDetailModel> _lessonCache = {};
  String? _lastLessonLoadError;
  String? get lastLessonLoadError => _lastLessonLoadError;
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
  final _db = AppDatabase.instance;
  final _syncManager = SyncManager.instance;
  final _outboxManager = OutboxManager.instance;

  Future<void> changeContentLanguage() async {
    _lessonCache.clear();
    await loadHomeData();
  }

  /// Fetch all courses + user stats in one go. Called on home screen load.
  ///
  /// Local-first: paints instantly from whatever's cached in the local
  /// Drift store (if anything), then syncs the delta manifest in the
  /// background and refreshes from the updated cache. If there's no local
  /// cache yet (first run) and the network also fails, this surfaces the
  /// same error state as before. If there IS a local cache and only the
  /// network step fails, we keep showing cached data instead of erroring --
  /// that's the whole point of caching for spotty Ethiopian mobile networks.
  ///
  Future<void> loadHomeData({bool showLoading = true}) async {
    if (showLoading && _courses.isEmpty) _status = ContentStatus.loading;
    _error = null;
    notifyListeners();

    await _db.migrateLegacyApiCacheIfPresent();
    await StarterCurriculumLoader.instance.seedIfEmpty();
    final cached = await _loadCoursesFromLocalDb();
    if (cached.isNotEmpty) {
      _courses = cached;
      _status = ContentStatus.loaded;
      notifyListeners();
    }

    try {
      await _syncManager.sync();
      final refreshed = await _loadCoursesFromLocalDb();
      if (refreshed.isNotEmpty) {
        _courses = refreshed;
      } else if (_courses.isEmpty) {
        // No local cache at all (fresh install, or sync produced nothing
        // usable) -- fall back to a direct network fetch like before.
        _courses = await _contentApi.getCourses();
      }

      try {
        _stats = await _progressApi.getMyStats();
      } catch (e) {
        if (kDebugMode) debugPrint('loadHomeData stats error: $e');
        _stats ??= const UserStatsModel(
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
      if (_courses.isEmpty) {
        _error = e.userMessage;
        _status = ContentStatus.error;
      }
    } on NetworkException catch (e) {
      if (_courses.isEmpty) {
        _error = e.message;
        _status = ContentStatus.error;
      }
    } catch (e) {
      if (_courses.isEmpty) {
        _error = 'Failed to load content.';
        _status = ContentStatus.error;
      }
      if (kDebugMode) debugPrint('ContentProvider.loadHomeData error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<List<CourseModel>> _loadCoursesFromLocalDb() async {
    try {
      final courses = await _db.getAllCourses();
      final result = <CourseModel>[];
      for (final course in courses) {
        final units = await _db.getUnitsForCourse(course.id);
        final unitModels = <UnitModel>[];
        for (final unit in units) {
          final lessons = await _db.getLessonsForUnit(unit.id);
          unitModels.add(
            UnitModel(
              id: unit.id,
              courseId: unit.courseId,
              unitKind: unit.unitKind,
              unitNo: unit.unitNo,
              title: unit.title,
              description: unit.description,
              createdAt: DateTime.now(),
              lessons: lessons
                  .map(
                    (l) => LessonModel(
                      id: l.id,
                      courseId: l.courseId,
                      unitId: l.unitId,
                      lessonKind: l.lessonKind,
                      sequenceNo: l.sequenceNo,
                      title: l.title,
                      description: l.description,
                      contentLanguage: l.contentLanguage,
                      estimatedMinutes: l.estimatedMinutes,
                      xpReward: l.xpReward,
                      isPublished: l.isPublished,
                    ),
                  )
                  .toList(),
            ),
          );
        }
        result.add(
          CourseModel(
            id: course.id,
            targetLanguageId: '',
            code: course.code,
            title: course.title,
            description: course.description,
            levelMin: course.levelMin,
            levelMax: course.levelMax,
            isPublished: course.isPublished,
            createdAt: DateTime.now(),
            units: unitModels,
          ),
        );
      }
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('_loadCoursesFromLocalDb error: $e');
      return [];
    }
  }

  /// Fetch full lesson detail (cached in-memory by lessonId, backed by the
  /// local Drift store, falling back to a direct network call if both
  /// misses -- e.g. before the first sync has ever run).
  Future<LessonDetailModel?> getLessonDetail(String lessonId) async {
    if (_lessonCache.containsKey(lessonId)) return _lessonCache[lessonId];
    try {
      final cachedRow = await _db.getLesson(lessonId);
      if (cachedRow?.detailJson != null) {
        final json = jsonDecode(cachedRow!.detailJson!) as Map<String, dynamic>;
        final detail = LessonDetailModel.fromJson(json);
        _lessonCache[lessonId] = detail;
        _lastLessonLoadError = null;
        return detail;
      }

      final json = await _syncManager.fetchAndCacheLessonDetail(lessonId);
      final detail = LessonDetailModel.fromJson(json);
      _lessonCache[lessonId] = detail;
      _lastLessonLoadError = null;
      notifyListeners();
      return detail;
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('getLessonDetail error: ${e.message}');
      _lastLessonLoadError = e.userMessage;
      return null;
    } on NetworkException catch (e) {
      _lastLessonLoadError = e.message;
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('getLessonDetail local-cache error: $e');
      try {
        final detail = await _contentApi.getLessonDetail(lessonId);
        _lessonCache[lessonId] = detail;
        _lastLessonLoadError = null;
        notifyListeners();
        return detail;
      } on ApiException catch (e) {
        _lastLessonLoadError = e.userMessage;
        return null;
      } on NetworkException catch (e) {
        _lastLessonLoadError = e.message;
        return null;
      } catch (_) {
        _lastLessonLoadError = null;
        return null;
      }
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

  /// Get the learner's next actionable lessons on their chapter journey.
  ///
  /// This mirrors the roadmap rules: lessons before an admin placement are
  /// treated as optional review, the assigned chapter opens at lesson one,
  /// and later chapters wait for the prior chapter to be completed.
  List<LessonModel> getIncompleteLessons(int count, {int startingUnitNo = 1}) {
    final incomplete = <LessonModel>[];
    for (final course in _courses) {
      final units = List<UnitModel>.of(course.units)
        ..sort((a, b) => a.unitNo.compareTo(b.unitNo));
      for (int unitIndex = 0; unitIndex < units.length; unitIndex++) {
        final unit = units[unitIndex];
        if (unit.unitNo < startingUnitNo) continue;
        final previousUnitComplete =
            unitIndex > 0 &&
            units[unitIndex - 1].lessons.every(
              (lesson) => isLessonCompleted(lesson.id),
            );
        final chapterUnlocked =
            unit.unitNo == startingUnitNo || previousUnitComplete;
        if (!chapterUnlocked) continue;
        final lessons = List<LessonModel>.of(unit.lessons)
          ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
        for (int i = 0; i < lessons.length; i++) {
          final lesson = lessons[i];
          if (!isLessonCompleted(lesson.id) && isLessonUnlocked(lessons, i)) {
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
  ///
  /// Goes through OutboxManager: tries the network immediately, and if the
  /// device is offline, queues the write locally instead of losing it (it's
  /// replayed automatically on the next successful sync). In that case the
  /// completion is marked locally right away -- the whole point of a
  /// local-first write path is that the learner isn't blocked on a round
  /// trip to see their lesson marked done.
  ///
  /// Returns null on a queued-offline write; callers already treat a null
  /// result as "fall back to the lesson's nominal XP reward for display"
  /// (see LessonCompleteScreen usage).
  ///
  /// A genuine rejection (ApiException -- the server actually said no, e.g.
  /// stale question IDs after a content sync) is intentionally NOT swallowed
  /// here: it propagates to the caller so the UI can tell the learner their
  /// lesson was not actually completed, instead of celebrating a completion
  /// that silently reverts the next time they open the app.
  Future<CompleteLessonResult?> completeLesson({
    required String lessonId,
    required double score,
    required List<AnswerPayload> answers,
    required int timeSeconds,
    int heartsSpent = 0,
  }) async {
    final existingProgress = _progressByLesson[lessonId];
    final result = await _outboxManager.submitLessonCompletion(
      lessonId: lessonId,
      score: score,
      answers: answers,
      timeSeconds: timeSeconds,
      heartsSpent: heartsSpent,
    );
    // Reached only on success or offline-queue -- a real rejection throws
    // out of the call above instead of falling through to here.
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
    // Refresh global stats (best-effort; skipped implicitly if offline
    // since getMyStats will also throw and just get swallowed here).
    try {
      _stats = await _progressApi.getMyStats();
    } catch (e) {
      if (kDebugMode) debugPrint('refresh stats after completion error: $e');
    }
    notifyListeners();
    return result;
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
  /// A genuine rejection (ApiException) propagates to the caller rather
  /// than being swallowed -- same reasoning as [completeLesson].
  Future<Map<String, dynamic>?> completeSrsReview({
    required List<AnswerPayload> answers,
    required int timeSeconds,
  }) async {
    final result = await _outboxManager.submitSrsReview(
      answers: answers,
      timeSeconds: timeSeconds,
    );

    // Refresh global stats after SRS
    try {
      _stats = await _progressApi.getMyStats();
    } catch (e) {
      if (kDebugMode) debugPrint('refresh stats after SRS error: $e');
    }
    notifyListeners();
    return result;
  }
}
