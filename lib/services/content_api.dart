import '../models/course_model.dart';
import '../models/culture_story_model.dart';
import '../core/app_localization.dart';
import 'api_client.dart';

/// Calls the Fluentian backend content endpoints.
class ContentApi {
  ContentApi._();
  static final ContentApi instance = ContentApi._();

  final _client = ApiClient.instance;

  String get _languageQuery =>
      'content_language=${Uri.encodeQueryComponent(AppLocaleController.activeLanguageCode)}';

  /// Fetch all published courses. Optionally filter by [level] (e.g. 'A1').
  Future<List<CourseModel>> getCourses({String? level}) async {
    final query = level != null
        ? '?level=${Uri.encodeQueryComponent(level)}&$_languageQuery'
        : '?$_languageQuery';
    final items = await _client.getList('/content/courses$query');
    return items
        .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single course with its units.
  Future<CourseModel> getCourse(String courseId) async {
    final json = await _client.get(
      '/content/courses/$courseId?$_languageQuery',
    );
    return CourseModel.fromJson(json);
  }

  /// Fetch units for a course.
  Future<List<UnitModel>> getCourseUnits(String courseId) async {
    final items = await _client.getList(
      '/content/courses/$courseId/units?$_languageQuery',
    );
    return items
        .map((e) => UnitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch full lesson detail (blocks + questions).
  Future<LessonDetailModel> getLessonDetail(String lessonId) async {
    final json = await _client.get(
      '/content/lessons/$lessonId?$_languageQuery',
    );
    return LessonDetailModel.fromJson(json);
  }

  /// Delta sync manifest: courses/units/lessons that changed since
  /// [since] (the device's last-synced global_content_version), plus the
  /// server's current global version. Pass since=0 for a full snapshot.
  Future<Map<String, dynamic>> getManifest({required int since}) async {
    return _client.get('/content/manifest?since=$since', auth: false);
  }

  /// Fetch only questions for a lesson (lighter call for quiz flow).
  Future<List<QuestionModel>> getLessonQuestions(String lessonId) async {
    final items = await _client.getList(
      '/content/lessons/$lessonId/questions?$_languageQuery',
    );
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

  /// Fetch due SRS questions
  Future<List<QuestionModel>> getDueSrsQuestions() async {
    final items = await _client.getList('/content/review');
    return items
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submit SRS review session
  Future<Map<String, dynamic>> completeSrsReview(
    List<Map<String, dynamic>> answers,
    int timeSeconds,
  ) async {
    final payload = {'answers': answers, 'time_seconds': timeSeconds};
    final response = await _client.post('/content/review/complete', payload);
    return response;
  }
}
