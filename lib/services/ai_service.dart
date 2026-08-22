import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'ai_cache_service.dart';
import '../core/app_localization.dart';

class AiMessage {
  final String role;
  final String content;
  final AiTutorActivity? activity;
  final String? keyPhrase;

  AiMessage({
    required this.role,
    required this.content,
    this.activity,
    this.keyPhrase,
  });

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiTutorActivity {
  final String type;
  final String question;
  final List<AiTutorActivityOption> options;
  final String explanation;

  const AiTutorActivity({
    required this.type,
    required this.question,
    required this.options,
    required this.explanation,
  });

  bool get isPoll => type.toLowerCase() == 'poll';

  factory AiTutorActivity.fromJson(Map<String, dynamic> json) {
    return AiTutorActivity(
      type: json['type']?.toString() ?? 'quiz',
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (option) => AiTutorActivityOption.fromJson(
              Map<String, dynamic>.from(option),
            ),
          )
          .toList(),
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class AiTutorActivityOption {
  final String text;
  final bool? isCorrect;
  final String? feedback;
  final int? votes;

  const AiTutorActivityOption({
    required this.text,
    this.isCorrect,
    this.feedback,
    this.votes,
  });

  factory AiTutorActivityOption.fromJson(Map<String, dynamic> json) {
    return AiTutorActivityOption(
      text: json['text']?.toString() ?? '',
      isCorrect: json['is_correct'] is bool ? json['is_correct'] as bool : null,
      feedback: json['feedback']?.toString(),
      votes: json['votes'] is int ? json['votes'] as int : null,
    );
  }
}

class AiTutorResponse {
  final String text;
  final AiTutorActivity? activity;
  final String? keyPhrase;

  const AiTutorResponse({required this.text, this.activity, this.keyPhrase});
}

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  Future<AiTutorResponse?> fetchQuickAction({
    required String action,
    required String contentId,
    required String contextText,
  }) async {
    final languageCode = AppLocaleController.activeLanguageCode;

    try {
      final localCached = await AiCacheService.instance.getCachedResponse(
        action: action,
        contentId: contentId,
        languageCode: languageCode,
      );

      Map<String, dynamic> responseData;
      if (localCached != null) {
        responseData = localCached;
      } else {
        responseData = await ApiClient.instance.post('/ai/quick-action', {
          'action': action,
          'content_id': contentId,
          'context_text': contextText,
          'content_language': languageCode,
        });

        await AiCacheService.instance.saveResponse(
          action: action,
          contentId: contentId,
          languageCode: languageCode,
          payload: responseData,
        );
      }

      final activityJson = responseData['activity'];
      return AiTutorResponse(
        text: responseData['text']?.toString() ?? '',
        activity: activityJson is Map
            ? AiTutorActivity.fromJson(Map<String, dynamic>.from(activityJson))
            : null,
        keyPhrase: responseData['key_phrase']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('AI Quick Action Exception: $e');
      return null;
    }
  }

  Future<AiTutorResponse?> generateText({
    required List<AiMessage> messages,
    String? systemContext,
  }) async {
    try {
      final data = await ApiClient.instance.post('/ai/chat', {
        'messages': messages.map((e) => e.toJson()).toList(),
        if (systemContext != null) 'systemContext': systemContext,
        'content_language': AppLocaleController.activeLanguageCode,
      });
      final activityJson = data['activity'];
      return AiTutorResponse(
        text: data['text']?.toString() ?? '',
        activity: activityJson is Map
            ? AiTutorActivity.fromJson(Map<String, dynamic>.from(activityJson))
            : null,
        keyPhrase: data['key_phrase']?.toString(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('AI Service exception: $e');
      return null;
    }
  }
}
