import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static const String _configuredBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://admin.fluentian.com',
  );

  String get _baseUrl {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return _configuredBaseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Future<String?> generateText({
    required List<AiMessage> messages,
    String? systemContext,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/ai/chat');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': messages.map((e) => e.toJson()).toList(),
          if (systemContext != null) 'systemContext': systemContext,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] as String?;
      } else {
        if (kDebugMode) {
          debugPrint(
            'AI Service error: ${response.statusCode} - ${response.body}',
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('AI Service exception: $e');
      return null;
    }
  }
}
