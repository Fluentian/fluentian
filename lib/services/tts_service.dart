import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'api_client.dart';
import 'media_cache_manager.dart';

/// Modular Interface for Audio & Text-To-Speech Providers.
abstract class BaseTtsProvider {
  Future<void> speak(
    String text, {
    String language = 'fr-FR',
    double speed = 1.0,
    String voiceId = 'claire',
  });
  Future<void> stop();
  bool get isSpeaking;
}

/// Cartesia.ai Cloud TTS Provider with Server Deduplication, Smart Slow Replay,
/// and 7-day Device Local File Caching.
class CartesiaCloudTtsProvider implements BaseTtsProvider {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final BaseTtsProvider _fallback = NativeDeviceTtsProvider();

  bool _speaking = false;
  String _lastText = '';
  bool _isSlowMode = false;

  @override
  bool get isSpeaking => _speaking || _fallback.isSpeaking;

  @override
  Future<void> speak(
    String text, {
    String language = 'fr-FR',
    double speed = 1.0,
    String voiceId = 'claire',
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await stop();

    // Smart Slow Replay Logic:
    // If the learner taps the exact same phrase again, toggle to Slow Turtle Speed (0.75x)
    double effectiveSpeed = speed;
    if (_lastText == cleanText) {
      _isSlowMode = !_isSlowMode;
      if (_isSlowMode) {
        effectiveSpeed = (speed * 0.75).clamp(0.5, 0.9);
      }
    } else {
      _lastText = cleanText;
      _isSlowMode = false;
    }

    try {
      _speaking = true;
      // 1. Call Backend Cartesia Synthesis (Server Object Storage Cached)
      final res = await ApiClient.instance.post(
        '/content/tts/synthesize',
        {
          'text': cleanText,
          'voice_id': voiceId,
          'speed': double.parse(effectiveSpeed.toStringAsFixed(2)),
        },
      );

      final relUrl = res['audio_url'] as String? ?? '';
      if (relUrl.isEmpty) {
        _speaking = false;
        await _fallback.speak(cleanText, language: language, speed: effectiveSpeed);
        return;
      }

      final fullUrl = ApiClient.resolveMediaUrl(relUrl) ?? relUrl;

      // 2. Play using Device Media Cache Manager (7-day local disk deadline)
      await MediaCacheManager.instance.loadIntoPlayer(_audioPlayer, fullUrl);
      await _audioPlayer.setSpeed(effectiveSpeed);
      await _audioPlayer.play();
      _speaking = false;
    } catch (e) {
      _speaking = false;
      if (kDebugMode) debugPrint('Cartesia TTS error, using native fallback: $e');
      await _fallback.speak(cleanText, language: language, speed: effectiveSpeed);
    }
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _fallback.stop();
    _speaking = false;
  }
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
    String voiceId = 'claire',
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
  TtsService._() {
    // Default to Cartesia Cloud TTS Engine with Native fallback
    _provider = CartesiaCloudTtsProvider();
  }

  static final TtsService instance = TtsService._();

  late BaseTtsProvider _provider;

  /// Register a custom cloud audio / TTS provider.
  void setProvider(BaseTtsProvider customProvider) {
    _provider = customProvider;
  }

  bool get isSpeaking => _provider.isSpeaking;

  Future<void> speak(
    String text, {
    String language = 'fr-FR',
    double speed = 1.0,
    String voiceId = 'claire',
  }) =>
      _provider.speak(text, language: language, speed: speed, voiceId: voiceId);

  Future<void> stop() => _provider.stop();
}
