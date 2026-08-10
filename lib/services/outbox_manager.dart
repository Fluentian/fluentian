import 'dart:convert';
import 'dart:math';

import '../local_db/app_database.dart';
import '../models/progress_model.dart';
import 'api_client.dart';
import 'app_logger.dart';
import 'progress_api.dart';

/// Local-first write path for lesson completions: try the network
/// immediately (the common case), and if that fails because the device is
/// offline, queue the request in the local outbox instead of losing it.
/// Queued entries are replayed by [flush], normally called from
/// SyncManager.sync() on reconnect/app-resume.
class OutboxManager {
  OutboxManager._();
  static final OutboxManager instance = OutboxManager._();

  final AppDatabase _db = AppDatabase.instance;
  final ProgressApi _progressApi = ProgressApi.instance;
  final Random _random = Random.secure();

  String _generateIdempotencyKey() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    final randomPart = base64UrlEncode(bytes).replaceAll('=', '');
    return '${DateTime.now().microsecondsSinceEpoch}-$randomPart';
  }

  /// Submit a lesson completion. Returns the server result if it went
  /// through immediately, or null if it was queued for later (the caller
  /// should treat null the same way it already treats a failed submission
  /// -- e.g. falling back to the lesson's nominal XP reward for display).
  Future<CompleteLessonResult?> submitLessonCompletion({
    required String lessonId,
    required double score,
    required List<AnswerPayload> answers,
    required int timeSeconds,
    int heartsSpent = 0,
  }) async {
    final idempotencyKey = _generateIdempotencyKey();
    try {
      return await _progressApi.completeLesson(
        lessonId: lessonId,
        score: score,
        answers: answers,
        timeSeconds: timeSeconds,
        heartsSpent: heartsSpent,
        idempotencyKey: idempotencyKey,
      );
    } on NetworkException {
      await _queue(
        lessonId: lessonId,
        idempotencyKey: idempotencyKey,
        score: score,
        answers: answers,
        timeSeconds: timeSeconds,
        heartsSpent: heartsSpent,
      );
      return null;
    }
    // Deliberately not catching ApiException here: a 4xx (bad request,
    // validation error) means the request itself is invalid and retrying
    // it unchanged would just fail again -- surface it to the caller
    // instead of silently queuing something that can never succeed.
  }

  Future<void> _queue({
    required String lessonId,
    required String idempotencyKey,
    required double score,
    required List<AnswerPayload> answers,
    required int timeSeconds,
    required int heartsSpent,
  }) async {
    final payload = {
      'score': score,
      'answers': answers.map((a) => a.toJson()).toList(),
      'time_seconds': timeSeconds,
      'hearts_spent': heartsSpent,
      'idempotency_key': idempotencyKey,
    };
    await _db.queueProgressWrite(
      lessonId: lessonId,
      idempotencyKey: idempotencyKey,
      requestPayloadJson: jsonEncode(payload),
    );
    await AppLogger.instance.info('Queued offline lesson completion for $lessonId');
  }

  /// Replay every queued completion. Best-effort: a queued entry is
  /// dropped once it either succeeds or comes back with a definitive 4xx
  /// (which would never succeed on retry); genuine network failures leave
  /// it queued for the next flush.
  Future<void> flush() async {
    final pending = await _db.getPendingOutboxEntries();
    for (final entry in pending) {
      try {
        final payload = jsonDecode(entry.requestPayloadJson) as Map<String, dynamic>;
        final answers = (payload['answers'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(
              (a) => AnswerPayload(
                questionId: a['question_id'] as String,
                answer: a['answer'],
                isCorrect: a['is_correct'] as bool,
              ),
            )
            .toList();
        await _progressApi.completeLesson(
          lessonId: entry.lessonId,
          score: (payload['score'] as num).toDouble(),
          answers: answers,
          timeSeconds: payload['time_seconds'] as int,
          heartsSpent: payload['hearts_spent'] as int? ?? 0,
          idempotencyKey: entry.idempotencyKey,
        );
        await _db.markOutboxEntrySynced(entry.localId);
      } on NetworkException {
        // Still offline -- leave it queued, try again on the next flush.
        break;
      } on ApiException catch (e) {
        // A definitive rejection (not a connectivity problem): record it
        // and move on rather than retrying forever.
        await _db.markOutboxEntryFailed(entry.localId, e.toString());
      } catch (e) {
        await _db.markOutboxEntryFailed(entry.localId, e.toString());
      }
    }
  }
}
