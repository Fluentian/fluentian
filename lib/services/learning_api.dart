import 'api_client.dart';

class LearningApi {
  LearningApi._();
  static final LearningApi instance = LearningApi._();

  final _client = ApiClient.instance;

  Future<void> submitLessonFeedback({
    required String lessonId,
    required int rating,
    required String category,
    String? comment,
  }) async {
    await _client.post('/learning/lessons/$lessonId/feedback', {
      'rating': rating,
      'category': category,
      'comment': comment,
    });
  }

  Future<Map<String, dynamic>> submitPlacement({
    required List<bool> answers,
    Map<String, dynamic> detail = const {},
  }) {
    return _client.post('/learning/placement/submit', {
      'answers': answers,
      'detail': detail,
    });
  }
}
