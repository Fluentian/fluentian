import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'api_client.dart';

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

/// Device Local File Cache Manager for Instant 0ms TTS Playback
class LocalTtsCacheManager {
  static const Map<String, String> voiceUuidMap = {
    'maya': '2f8e82c4-cb94-4e6d-8b6a-29bf58ceb60a',
    'sofia': '63fdecc2-4e1d-4aa3-a442-27204e3cd3b5',
    'sami': 'ce74c4da-4aee-435d-bc6d-81d1a9367e12',
    'daniel': 'd9f4af15-c402-4f50-bbda-d8823d028d6a',
    'claire': '2f8e82c4-cb94-4e6d-8b6a-29bf58ceb60a',
    'elodie': '63fdecc2-4e1d-4aa3-a442-27204e3cd3b5',
    'antoine': 'ce74c4da-4aee-435d-bc6d-81d1a9367e12',
    'lucas': 'd9f4af15-c402-4f50-bbda-d8823d028d6a',
  };

  static Future<File> getCacheFile(String voiceId, double speed, String text) async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/tts_cache');
    if (!cacheDir.existsSync()) {
      await cacheDir.create(recursive: true);
    }
    final keyStr = voiceId.toLowerCase().trim();
    final uuid = voiceUuidMap[keyStr] ?? keyStr;
    final rawKey = '${uuid}_${speed.toStringAsFixed(2)}_${text.trim()}';
    final hash = sha256.convert(utf8.encode(rawKey)).toString();
    return File('${cacheDir.path}/$hash.mp3');
  }
}

/// Cartesia.ai Cloud TTS Provider with Zero-Latency Local Audio Disk Caching,
/// Smart Slow Replay, and Gender-Differentiated Fallback.
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

    // 1. FAST PATH: Check Device Local Audio File Disk Cache (0ms latency, 0 network requests)
    try {
      final cacheFile = await LocalTtsCacheManager.getCacheFile(voiceId, effectiveSpeed, cleanText);
      if (await cacheFile.exists() && (await cacheFile.length()) > 0) {
        _speaking = true;
        await _audioPlayer.setFilePath(cacheFile.path);
        await _audioPlayer.setSpeed(effectiveSpeed);
        await _audioPlayer.play();
        _speaking = false;
        return;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Local TTS disk cache check error: $e');
    }

    // 2. NETWORK PATH: Synthesize from Server / Cloud Engine
    try {
      _speaking = true;
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
        await _fallback.speak(cleanText, language: language, speed: effectiveSpeed, voiceId: voiceId);
        return;
      }

      final fullUrl = ApiClient.resolveMediaUrl(relUrl) ?? relUrl;

      // 1. Immediately stream and play audio (< 1s latency)
      await _audioPlayer.setUrl(fullUrl);
      await _audioPlayer.setSpeed(effectiveSpeed);
      
      // 2. Cache file to local disk asynchronously in background (non-blocking)
      unawaited(() async {
        try {
          final cacheFile = await LocalTtsCacheManager.getCacheFile(voiceId, effectiveSpeed, cleanText);
          if (!await cacheFile.exists()) {
            final client = HttpClient();
            final request = await client.getUrl(Uri.parse(fullUrl));
            final response = await request.close();
            if (response.statusCode == 200) {
              final bytes = await response.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
              await cacheFile.writeAsBytes(bytes);
            }
          }
        } catch (_) {}
      }());

      await _audioPlayer.play();
      _speaking = false;
    } catch (e) {
      _speaking = false;
      if (kDebugMode) debugPrint('Cartesia TTS error, using voice-differentiated native fallback: $e');
      await _fallback.speak(cleanText, language: language, speed: effectiveSpeed, voiceId: voiceId);
    }
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _fallback.stop();
    _speaking = false;
  }
}

/// System Native TTS Implementation using flutter_tts with Gender & Voice Identity Tuning
class NativeDeviceTtsProvider implements BaseTtsProvider {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _speaking = false;
  List<dynamic>? _cachedVoices;

  @override
  bool get isSpeaking => _speaking;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setVolume(1.0);
    _tts.setStartHandler(() => _speaking = true);
    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setCancelHandler(() => _speaking = false);
    _tts.setErrorHandler((message) {
      _speaking = false;
      if (kDebugMode) debugPrint('TTS engine error: $message');
    });
    try {
      _cachedVoices = await _tts.getVoices;
    } catch (_) {}
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

    final vId = voiceId.toLowerCase().trim();
    double pitch = 1.0;
    if (vId == 'sami' || vId == 'antoine') {
      pitch = 0.76;
    } else if (vId == 'daniel' || vId == 'lucas') {
      pitch = 0.85;
    } else if (vId == 'sofia' || vId == 'elodie') {
      pitch = 1.28;
    } else {
      pitch = 1.12;
    }
    await _tts.setPitch(pitch);

    // Use cached voices list for fast lookup
    try {
      final voices = _cachedVoices ?? await _tts.getVoices;
      _cachedVoices = voices as List<dynamic>?;
      if (voices is List) {
        for (final v in voices) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            final loc = (v['locale'] ?? '').toString().toLowerCase();
            if (loc.startsWith('fr')) {
              final isMale = vId == 'sami' || vId == 'daniel' || vId == 'antoine' || vId == 'lucas';
              if (isMale && (name.contains('male') || name.contains('man') || name.contains('c-local') || name.contains('d-local'))) {
                await _tts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              } else if (!isMale && (name.contains('female') || name.contains('woman') || name.contains('a-local') || name.contains('b-local'))) {
                await _tts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              }
            }
          }
        }
      }
    } catch (_) {}

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
    _provider = CartesiaCloudTtsProvider();
  }

  static final TtsService instance = TtsService._();

  late BaseTtsProvider _provider;

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
