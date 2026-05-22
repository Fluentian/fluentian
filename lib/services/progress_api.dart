import '../models/progress_model.dart';
import 'api_client.dart';

/// Calls the Fluentian backend progress endpoints.
class ProgressApi {
  ProgressApi._();
  static final ProgressApi instance = ProgressApi._();

  final _client = ApiClient.instance;

  /// Submit lesson completion. Returns XP earned, streak, hearts, etc.
  Future<CompleteLessonResult> completeLesson({
    required String lessonId,
    required double score,
    required List<AnswerPayload> answers,
    required int timeSeconds,
  }) async {
    final json = await _client.post(
      '/progress/lessons/$lessonId/complete',
      {
        'score': score,
        'answers': answers.map((a) => a.toJson()).toList(),
        'time_seconds': timeSeconds,
      },
    );
    return CompleteLessonResult.fromJson(json);
  }

  /// Fetch the current user's lesson progress list.
  /// [completed] filters: true = completed only, false = incomplete only, null = all.
  Future<List<LessonProgressModel>> getMyLessonProgress({
    bool? completed,
  }) async {
    final query = completed != null ? '?completed=$completed' : '';
    final items = await _client.getList('/progress/me/lessons$query');
    return items
        .map((e) => LessonProgressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the current user's aggregate stats.
  Future<UserStatsModel> getMyStats() async {
    final json = await _client.get('/progress/me/stats');
    return UserStatsModel.fromJson(json);
  }

  /// Enroll the current user in a course.
  Future<void> enrollInCourse(String courseId) async {
    await _client.post('/progress/enroll/$courseId', {});
  }
}
