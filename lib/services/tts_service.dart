import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class TtsService {
  TtsService._() {
    _player = AudioPlayer();
  }

  static final TtsService instance = TtsService._();

  late final AudioPlayer _player;
  String? _activeLanguage;

  Future<void> speak(
    String text, {
    String language = 'fr',
    double speed = 1.0,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      _activeLanguage = language;
      await stop();
      await _player.setSpeed(speed.clamp(0.6, 1.6));

      final String googleTtsUrl =
          'https://translate.google.com/translate_tts'
          '?ie=UTF-8'
          '&q=${Uri.encodeComponent(cleanText)}'
          '&tl=$language'
          '&client=tw-ob';

      if (kDebugMode) {
        final previewLength = cleanText.length.clamp(0, 60).toInt();
        debugPrint(
          'TTS speak URL request for language=$_activeLanguage text="${cleanText.substring(0, previewLength)}"',
        );
      }

      await _player.setUrl(googleTtsUrl);
      await _player.play();
    } catch (e) {
      if (kDebugMode) debugPrint('TTS playback error: $e');
      // If network fails, we just silently fail or log it
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }
}
