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
    'maya': 'a249eaff-1e96-4d2c-b23b-12efa4f66f41',
    'sofia': '8832a0b5-47b2-4751-bb22-6a8e2149303d',
    'sami': '30894953-bcce-41fe-892c-15ce19c843ff',   // Parker - casual young male
    'daniel': '56df0456-8f47-4f7a-ac26-40c2f9797104', // Pierre Baritone - deep resonant
    'claire': 'a249eaff-1e96-4d2c-b23b-12efa4f66f41',
    'elodie': '8832a0b5-47b2-4751-bb22-6a8e2149303d',
    'antoine': '30894953-bcce-41fe-892c-15ce19c843ff',
    'lucas': '56df0456-8f47-4f7a-ac26-40c2f9797104',
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
    final isFemale = vId == 'maya' || vId == 'sofia' || vId == 'claire' || vId == 'elodie';

    double pitch = 1.0;
    if (vId == 'maya' || vId == 'claire') {
      pitch = 1.30;
    } else if (vId == 'sofia' || vId == 'elodie') {
      pitch = 1.45;
    } else if (vId == 'sami' || vId == 'antoine') {
      pitch = 0.74;
    } else if (vId == 'daniel' || vId == 'lucas') {
      pitch = 0.82;
    }
    await _tts.setPitch(pitch);

    // Use cached voices list for fast lookup
    try {
      final voices = _cachedVoices ?? await _tts.getVoices;
      _cachedVoices = voices as List<dynamic>?;
      if (voices is List) {
        final frVoices = voices.where((v) {
          if (v is! Map) return false;
          final loc = (v['locale'] ?? '').toString().toLowerCase();
          return loc.startsWith('fr');
        }).toList();

        Map? selectedVoice;
        for (final v in frVoices) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString().toLowerCase();
            if (isFemale) {
              if (name.contains('female') || name.contains('femme') || name.contains('woman') ||
                  name.contains('-a-') || name.contains('-c-') || name.contains('vbf') || name.contains('vif') || name.contains('a-local') || name.contains('c-local')) {
                selectedVoice = v;
                break;
              }
            } else {
              if (name.contains('male') || name.contains('homme') || name.contains('man') ||
                  name.contains('-b-') || name.contains('-d-') || name.contains('vbm') || name.contains('vim') || name.contains('b-local') || name.contains('d-local')) {
                selectedVoice = v;
                break;
              }
            }
          }
        }

        // Fallback: If no explicit gender keyword match, pick first French voice for female, second for male
        if (selectedVoice == null && frVoices.isNotEmpty) {
          if (isFemale) {
            selectedVoice = frVoices.first as Map;
          } else if (frVoices.length > 1) {
            selectedVoice = frVoices[1] as Map;
          }
        }

        if (selectedVoice != null) {
          await _tts.setVoice({"name": selectedVoice['name'], "locale": selectedVoice['locale']});
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
