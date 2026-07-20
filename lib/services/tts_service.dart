import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Shared native text-to-speech service used by lessons, quizzes, and Word Bank.
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _speaking = false;

  bool get isSpeaking => _speaking;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => _speaking = true);
    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setCancelHandler(() => _speaking = false);
    _tts.setErrorHandler((message) {
      _speaking = false;
      if (kDebugMode) debugPrint('TTS engine error: $message');
    });
    _initialized = true;
  }

  Future<void> speak(
    String text, {
    String language = 'fr-FR',
    double speed = 1.0,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await _initialize();
    await stop();

    final locale = language.trim().isEmpty
        ? 'fr-FR'
        : language.contains('-')
        ? language
        : language.toLowerCase() == 'fr'
        ? 'fr-FR'
        : language;

    final available = await _tts.isLanguageAvailable(locale);
    if (available != true && locale != 'fr-FR') {
      await _tts.setLanguage('fr-FR');
    } else {
      await _tts.setLanguage(locale);
    }

    // flutter_tts uses a platform-relative 0.0–1.0 rate. Map Fluentian's
    // user-facing 0.6x–1.6x control to a natural native range.
    final normalizedRate = (0.42 + ((speed.clamp(0.6, 1.6) - 0.6) * 0.23))
        .clamp(0.35, 0.72);
    await _tts.setSpeechRate(normalizedRate);

    final result = await _tts.speak(cleanText);
    if (result != 1) {
      _speaking = false;
      throw StateError('The device text-to-speech engine could not start.');
    }
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _tts.stop();
    _speaking = false;
  }
}
