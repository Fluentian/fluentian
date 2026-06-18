import '../models/course_model.dart';
import '../models/culture_story_model.dart';
import 'api_client.dart';

/// Calls the Fluentian backend content endpoints.
class ContentApi {
  ContentApi._();
  static final ContentApi instance = ContentApi._();

  final _client = ApiClient.instance;

  /// Fetch all published courses. Optionally filter by [level] (e.g. 'A1').
  Future<List<CourseModel>> getCourses({String? level}) async {
    final query = level != null ? '?level=$level' : '';
    final items = await _client.getList('/content/courses$query');
    return items
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single course with its units.
  Future<CourseModel> getCourse(String courseId) async {
    final json = await _client.get('/content/courses/$courseId');
    return CourseModel.fromJson(json);
  }

  /// Fetch units for a course.
  Future<List<UnitModel>> getCourseUnits(String courseId) async {
    final items = await _client.getList('/content/courses/$courseId/units');
    return items
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch full lesson detail (blocks + questions).
  Future<LessonDetailModel> getLessonDetail(String lessonId) async {
    final json = await _client.get('/content/lessons/$lessonId');
    return LessonDetailModel.fromJson(json);
  }

  /// Fetch only questions for a lesson (lighter call for quiz flow).
  Future<List<QuestionModel>> getLessonQuestions(String lessonId) async {
    final items = await _client.getList('/content/lessons/$lessonId/questions');
    return items
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch published culture exploration stories for the Explore tab.
  Future<List<CultureStoryModel>> getCultureStories() async {
    final items = await _client.getList(
      '/content/culture-stories',
      auth: false,
    );
    return items
        .map((e) => CultureStoryModel.fromJson(e as Map<String, dynamic>))
        .where((story) => story.media.isNotEmpty && story.paragraphs.isNotEmpty)
        .toList();
  }
}
