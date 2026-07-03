import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AiMessage {
  final String role;
  final String content;
  final AiTutorActivity? activity;

  AiMessage({required this.role, required this.content, this.activity});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
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
          .map((option) => AiTutorActivityOption.fromJson(
                Map<String, dynamic>.from(option),
              ))
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

  const AiTutorResponse({required this.text, this.activity});
}

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  Future<AiTutorResponse?> generateText({
    required List<AiMessage> messages,
    String? systemContext,
  }) async {
    try {
      final data = await ApiClient.instance.post('/ai/chat', {
        'messages': messages.map((e) => e.toJson()).toList(),
        if (systemContext != null) 'systemContext': systemContext,
      });
      final activityJson = data['activity'];
      return AiTutorResponse(
        text: data['text']?.toString() ?? '',
        activity: activityJson is Map
            ? AiTutorActivity.fromJson(Map<String, dynamic>.from(activityJson))
            : null,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('AI Service exception: $e');
      return null;
    }
  }
}
