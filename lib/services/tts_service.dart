import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> speak(
    String text, {
    String language = 'fr-FR',
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      await _configure(language);
      await _tts.stop();
      await _tts.speak(cleanText);
    } catch (e) {
      if (kDebugMode) debugPrint('TTS playback error: $e');
      rethrow;
    }
  }

  Future<void> stop() => _tts.stop();

  Future<void> _configure(String language) async {
    if (_configured) {
      await _tts.setLanguage(language);
      return;
    }

    await _tts.setLanguage(language);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(false);
    _configured = true;
  }
}
