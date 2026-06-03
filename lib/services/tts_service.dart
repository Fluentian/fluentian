import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;
  String? _activeLanguage;

  Future<void> speak(String text, {String language = 'fr-FR'}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    try {
      await _configure(language);
      await _tts.stop();
      final result = await _tts.speak(cleanText);
      if (kDebugMode) {
        final previewLength = cleanText.length.clamp(0, 60).toInt();
        debugPrint(
          'TTS speak result=$result language=$_activeLanguage text="${cleanText.substring(0, previewLength)}"',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('TTS playback error: $e');
      rethrow;
    }
  }

  Future<void> stop() => _tts.stop();

  Future<void> _configure(String language) async {
    if (!_configured) {
      await _preferGoogleTtsEngine();
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _configured = true;
    }

    final usableLanguage = await _resolveLanguage(language);
    await _tts.setLanguage(usableLanguage);
    _activeLanguage = usableLanguage;
  }

  Future<void> _preferGoogleTtsEngine() async {
    try {
      final engines = await _tts.getEngines;
      if (kDebugMode) debugPrint('TTS engines: $engines');
      if (engines is List &&
          engines.any(
            (engine) => engine.toString() == 'com.google.android.tts',
          )) {
        await _tts.setEngine('com.google.android.tts');
        if (kDebugMode) {
          debugPrint('TTS engine selected: com.google.android.tts');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('TTS engine selection skipped: $e');
    }
  }

  Future<String> _resolveLanguage(String requested) async {
    final candidates = <String>[
      requested,
      requested.replaceAll('_', '-'),
      requested.split(RegExp('[-_]')).first,
      'fr-FR',
      'fr',
      'en-US',
    ].where((value) => value.trim().isNotEmpty).toSet();

    for (final candidate in candidates) {
      try {
        final available = await _tts.isLanguageAvailable(candidate);
        if (kDebugMode) {
          debugPrint('TTS language candidate=$candidate available=$available');
        }
        if (available == true ||
            available == 1 ||
            available.toString() == '1') {
          return candidate;
        }
      } catch (_) {}
    }

    if (kDebugMode) {
      try {
        final languages = await _tts.getLanguages;
        debugPrint(
          'TTS no preferred language available. Installed languages: $languages',
        );
      } catch (_) {}
    }

    return requested;
  }
}
