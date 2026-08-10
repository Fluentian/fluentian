import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../local_db/app_database.dart';
import 'app_logger.dart';
import 'content_api.dart';

/// Pulls the delta manifest from the backend and applies it to the local
/// Drift store. Cheap to call often (e.g. on app resume): with nothing
/// changed server-side, it's a single small GET.
class SyncManager {
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  final AppDatabase _db = AppDatabase.instance;
  final ContentApi _contentApi = ContentApi.instance;

  bool _isSyncing = false;

  /// Fetch and apply the delta manifest. Returns true if anything changed.
  /// A concurrent call while a sync is already running is a no-op (returns
  /// false) rather than queuing -- callers that need to know the outcome
  /// should await the in-flight call's result via [syncing] instead of
  /// firing a second one.
  Future<bool> sync({bool forceFullResync = false}) async {
    if (_isSyncing) return false;
    _isSyncing = true;
    try {
      final since = forceFullResync ? 0 : await _db.getLastSyncedGlobalVersion();
      final manifest = await _contentApi.getManifest(since: since);
      final globalVersion = manifest['global_version'] as int? ?? since;
      final courses = (manifest['courses'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      var changed = false;
      for (final course in courses) {
        await _applyCourse(course);
        changed = true;
      }

      await _db.setLastSyncedGlobalVersion(globalVersion);
      await AppLogger.instance.info(
        'Sync: since=$since -> global=$globalVersion, ${courses.length} course(s) changed',
      );
      return changed;
    } catch (e) {
      // Sync failures are non-fatal: the app keeps working off whatever is
      // already cached locally (or falls back to live network reads, see
      // ContentProvider). Log and let the caller move on.
      await AppLogger.instance.error('Sync failed', e);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _applyCourse(Map<String, dynamic> course) async {
    final courseId = course['id'] as String;
    await _db.upsertCourse(
      CachedCoursesCompanion(
        id: Value(courseId),
        code: Value(course['code'] as String),
        levelMin: Value(course['level_min'] as String),
        levelMax: Value(course['level_max'] as String),
        contentVersion: Value(course['content_version'] as int),
        isPublished: const Value(true),
      ),
    );

    final units = (course['units'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final unit in units) {
      await _applyUnit(courseId, unit);
    }
  }

  Future<void> _applyUnit(String courseId, Map<String, dynamic> unit) async {
    final unitId = unit['id'] as String;
    await _db.upsertUnit(
      CachedUnitsCompanion(
        id: Value(unitId),
        courseId: Value(courseId),
        unitKind: Value(unit['unit_kind'] as String),
        unitNo: Value(unit['unit_no'] as int),
        title: Value(unit['title'] as String),
        contentVersion: Value(unit['content_version'] as int),
      ),
    );

    final lessons = (unit['lessons'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final lesson in lessons) {
      await _applyLesson(courseId, unitId, lesson);
    }
  }

  Future<void> _applyLesson(
    String courseId,
    String unitId,
    Map<String, dynamic> lesson,
  ) async {
    final lessonId = lesson['id'] as String;
    final newVersion = lesson['content_version'] as int;

    // The manifest only lists lessons whose content actually changed, so
    // any lesson reaching this point needs its cached full detail (blocks
    // + questions) re-fetched next time it's opened. We don't eagerly
    // re-fetch here to avoid an unbounded burst of requests on a big sync;
    // ContentProvider re-fetches lazily when detailJson is stale/missing.
    final existing = await _db.getLesson(lessonId);
    final detailIsStale = existing == null || existing.contentVersion != newVersion;

    await _db.upsertLesson(
      CachedLessonsCompanion(
        id: Value(lessonId),
        unitId: Value(unitId),
        courseId: Value(courseId),
        lessonKind: Value(lesson['lesson_kind'] as String),
        sequenceNo: Value(lesson['sequence_no'] as int),
        title: Value(lesson['title'] as String),
        estimatedMinutes: Value(lesson['estimated_minutes'] as int),
        xpReward: Value(lesson['xp_reward'] as int),
        isPublished: Value(lesson['is_published'] as bool),
        contentVersion: Value(newVersion),
        detailJson: detailIsStale ? const Value(null) : Value(existing.detailJson),
        detailFetchedAt: detailIsStale ? const Value(null) : Value(existing.detailFetchedAt),
      ),
    );
  }

  /// Fetch a lesson's full detail from the network and cache it locally.
  /// Called lazily by ContentProvider when a cached row has no (or stale)
  /// detailJson, and eagerly by the unit-download flow.
  Future<Map<String, dynamic>> fetchAndCacheLessonDetail(String lessonId) async {
    final detail = await _contentApi.getLessonDetail(lessonId);
    final json = {
      'id': detail.id,
      'course_id': detail.courseId,
      'unit_id': detail.unitId,
      'lesson_kind': detail.lessonKind,
      'sequence_no': detail.sequenceNo,
      'title': detail.title,
      'estimated_minutes': detail.estimatedMinutes,
      'xp_reward': detail.xpReward,
      'is_published': detail.isPublished,
      'blocks': detail.blocks
          .map(
            (b) => {
              'id': b.id,
              'lesson_id': b.lessonId,
              'block_kind': b.blockKind,
              'sequence_no': b.sequenceNo,
              'block_payload': b.blockPayload,
              'created_at': b.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'questions': detail.questions
          .map(
            (q) => {
              'id': q.id,
              'lesson_id': q.lessonId,
              'question_kind': q.questionKind,
              'sequence_no': q.sequenceNo,
              'difficulty': q.difficulty,
              'prompt_payload': q.promptPayload,
              'grading_payload': q.gradingPayload,
              'created_at': q.createdAt.toIso8601String(),
            },
          )
          .toList(),
    };
    await _db.saveLessonDetail(lessonId, jsonEncode(json));
    return json;
  }
}
