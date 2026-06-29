import 'package:flutter/foundation.dart';
import 'api_client.dart';

class AiMessage {
  final String role;
  final String content;

  AiMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  Future<String?> generateText({
    required List<AiMessage> messages,
    String? systemContext,
  }) async {
    try {
      final data = await ApiClient.instance.post('/ai/chat', {
        'messages': messages.map((e) => e.toJson()).toList(),
        if (systemContext != null) 'systemContext': systemContext,
      });
      return data['text'] as String?;
    } catch (e) {
      if (kDebugMode) debugPrint('AI Service exception: $e');
      return null;
    }
  }
}
