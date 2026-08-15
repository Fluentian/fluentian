import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Modular Interface for Audio & Text-To-Speech Providers.
/// Easily swap native device TTS, Google Cloud TTS, ElevenLabs, or OpenAI Audio.
abstract class BaseTtsProvider {
  Future<void> speak(String text, {String language = 'fr-FR', double speed = 1.0});
  Future<void> stop();
  bool get isSpeaking;
}

/// System Native TTS Implementation using flutter_tts
class NativeDeviceTtsProvider implements BaseTtsProvider {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _speaking = false;

  @override
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

  @override
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

    final normalizedRate = (0.42 + ((speed.clamp(0.6, 1.6) - 0.6) * 0.23))
        .clamp(0.35, 0.72);
    await _tts.setSpeechRate(normalizedRate);

    final result = await _tts.speak(cleanText);
    if (result != 1) {
      _speaking = false;
      throw StateError('The device text-to-speech engine could not start.');
    }
  }

  @override
  Future<void> stop() async {
    if (!_initialized) return;
    await _tts.stop();
    _speaking = false;
  }
}

/// Shared central access point for TTS playback across the app.
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  // Active provider (can be swapped for ElevenLabs / OpenAI / Google Cloud)
  BaseTtsProvider _provider = NativeDeviceTtsProvider();

  /// Register a custom cloud audio / TTS provider.
  void setProvider(BaseTtsProvider customProvider) {
    _provider = customProvider;
  }

  bool get isSpeaking => _provider.isSpeaking;

  Future<void> speak(
    String text, {
    String language = 'fr-FR',
    double speed = 1.0,
  }) =>
      _provider.speak(text, language: language, speed: speed);

  Future<void> stop() => _provider.stop();
}
