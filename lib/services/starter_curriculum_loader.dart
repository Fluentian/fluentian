import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;

import '../local_db/app_database.dart';
import '../core/app_localization.dart';

/// Seeds a tiny versioned French path before the first network sync.
/// The backend manifest remains authoritative and overwrites these rows once
/// connectivity is available.
class StarterCurriculumLoader {
  StarterCurriculumLoader._();
  static final instance = StarterCurriculumLoader._();

  static const _asset = 'assets/starter_curriculum.json';
  static const _seedMarker = 'starter_curriculum_seeded';

  final _db = AppDatabase.instance;

  Future<void> seedIfEmpty() async {
    // Never expose canonical English metadata when a learner explicitly chose
    // an explanation language without a bundled translation.
    if (AppLocaleController.activeLanguageCode != 'en') return;
    if ((await _db.getAllCourses()).isNotEmpty) return;
    final existing = await _db.getApiCache<bool>(_seedMarker);
    if (existing == true) return;
    final root =
        jsonDecode(await rootBundle.loadString(_asset)) as Map<String, dynamic>;
    final language = root['content_language'] as String? ?? 'en';
    for (final course
        in (root['courses'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>()) {
      final courseId = course['id'] as String;
      await _db.upsertCourse(
        CachedCoursesCompanion(
          id: Value(courseId),
          code: Value(course['code'] as String),
          title: Value(course['title'] as String),
          description: Value(course['description'] as String? ?? ''),
          levelMin: Value(course['level_min'] as String),
          levelMax: Value(course['level_max'] as String),
          contentVersion: const Value(0),
          isPublished: const Value(true),
          contentLanguage: Value(language),
        ),
      );
      for (final unit
          in (course['units'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>()) {
        final unitId = unit['id'] as String;
        await _db.upsertUnit(
          CachedUnitsCompanion(
            id: Value(unitId),
            courseId: Value(courseId),
            unitKind: Value(unit['unit_kind'] as String),
            unitNo: Value(unit['unit_no'] as int),
            title: Value(unit['title'] as String),
            description: Value(unit['description'] as String? ?? ''),
            contentVersion: const Value(0),
            contentLanguage: Value(language),
          ),
        );
        for (final lesson
            in (unit['lessons'] as List<dynamic>? ?? [])
                .cast<Map<String, dynamic>>()) {
          final lessonId = lesson['id'] as String;
          final detail = {
            'id': lessonId,
            'course_id': courseId,
            'unit_id': unitId,
            'lesson_kind': lesson['lesson_kind'],
            'sequence_no': lesson['sequence_no'],
            'title': lesson['title'],
            'description': lesson['description'] ?? '',
            'content_language': language,
            'estimated_minutes': lesson['estimated_minutes'],
            'xp_reward': lesson['xp_reward'],
            'is_published': true,
            'blocks': lesson['blocks'] ?? [],
            'questions': _canonicalQuestions(
              (lesson['questions'] as List<dynamic>? ?? [])
                  .cast<Map<String, dynamic>>(),
              lessonId,
            ),
          };
          await _db.upsertLesson(
            CachedLessonsCompanion(
              id: Value(lessonId),
              courseId: Value(courseId),
              unitId: Value(unitId),
              lessonKind: Value(lesson['lesson_kind'] as String),
              sequenceNo: Value(lesson['sequence_no'] as int),
              title: Value(lesson['title'] as String),
              description: Value(lesson['description'] as String? ?? ''),
              estimatedMinutes: Value(lesson['estimated_minutes'] as int),
              xpReward: Value(lesson['xp_reward'] as int),
              isPublished: const Value(true),
              contentVersion: const Value(0),
              contentLanguage: Value(language),
              detailJson: Value(jsonEncode(detail)),
              detailFetchedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }
    await _db.putApiCache(_seedMarker, true);
  }

  /// Bundled questions are authored in a flat shape (`kind`/`prompt`/`options`/
  /// `correct_answer`), but `QuestionModel.fromJson` hard-casts the canonical
  /// server shape (`question_kind`/`prompt_payload`/`grading_payload` + required
  /// `lesson_id`/`sequence_no`/`created_at`). Seeding the raw shape makes the
  /// model throw on parse, so translate here before it hits the cache.
  static List<Map<String, dynamic>> _canonicalQuestions(
    List<Map<String, dynamic>> raw,
    String lessonId,
  ) {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < raw.length; i++) {
      final q = raw[i];
      // Already canonical (future-proof): pass through with required defaults.
      if (q.containsKey('question_kind')) {
        out.add({
          'lesson_id': lessonId,
          'sequence_no': i + 1,
          'difficulty': 1,
          'prompt_payload': <String, dynamic>{},
          'grading_payload': <String, dynamic>{},
          'created_at': nowIso,
          ...q,
        });
        continue;
      }
      final promptPayload = <String, dynamic>{
        'question': q['prompt'] ?? q['question'] ?? q['text'] ?? '',
      };
      if (q['options'] != null) promptPayload['options'] = q['options'];
      if (q['explanation'] != null) {
        promptPayload['explanation'] = q['explanation'];
      }
      final gradingPayload = <String, dynamic>{};
      if (q['correct_answer'] != null) {
        gradingPayload['correct_answer'] = q['correct_answer'];
      }
      out.add({
        'id': q['id'],
        'lesson_id': lessonId,
        'question_kind': _mapKind(q['kind'] as String?),
        'sequence_no': i + 1,
        'difficulty': 1,
        'prompt_payload': promptPayload,
        'grading_payload': gradingPayload,
        'created_at': nowIso,
      });
    }
    return out;
  }

  static String _mapKind(String? authoringKind) {
    switch (authoringKind) {
      case 'multiple_choice':
      case 'mcq':
        return 'mcq_single';
      case 'multiple_select':
        return 'mcq_multi';
      default:
        return authoringKind ?? 'mcq_single';
    }
  }
}
