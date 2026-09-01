import 'package:firebase_analytics/firebase_analytics.dart';
import 'api_client.dart';

/// Small, privacy-conscious event facade. Keep event names stable so the
/// existing admin funnel can consume them later without coupling screens to
/// the Firebase SDK.
class ProductAnalytics {
  ProductAnalytics._();
  static final instance = ProductAnalytics._();
  final _analytics = FirebaseAnalytics.instance;

  Future<void> event(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {
      // Observability must never break learning.
    }
    try {
      await ApiClient.instance.post('/telemetry/events', {
        'name': name,
        'properties': parameters ?? <String, Object>{},
      });
    } catch (_) {}
  }

  Future<void> onboardingDone() => event('onboarding_done');
  Future<void> lessonStarted(String lessonId) =>
      event('lesson_started', parameters: {'lesson_id': lessonId});
  Future<void> lessonCompleted(String lessonId) =>
      event('lesson_completed', parameters: {'lesson_id': lessonId});
  Future<void> aiCallCustomized() => event('ai_call_customized');
  Future<void> scenarioStarted(String id) =>
      event('scenario_started', parameters: {'scenario_id': id});
  Future<void> scenarioGoalCompleted(String id) =>
      event('scenario_goal_completed', parameters: {'scenario_id': id});
  Future<void> feedbackReportViewed(String id) =>
      event('feedback_report_viewed', parameters: {'call_id': id});
}
