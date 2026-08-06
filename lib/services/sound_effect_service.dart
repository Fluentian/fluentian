import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum SoundEffect {
  aiResponse('assets/sounds/ai-response.mp3'),
  correct('assets/sounds/correct-sound.mp3'),
  wrong('assets/sounds/wrong-sound.mp3'),
  result('assets/sounds/result-sound.mp3');

  final String assetPath;

  const SoundEffect(this.assetPath);
}

class SoundEffectService {
  SoundEffectService._();
  static final SoundEffectService instance = SoundEffectService._();

  Future<void> play(SoundEffect effect) async {
    final player = AudioPlayer();
    try {
      await player.setAsset(effect.assetPath);
      await player.play();
      await player.processingStateStream
          .firstWhere((state) => state == ProcessingState.completed)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sound effect playback failed: ${effect.assetPath} $e');
      }
    } finally {
      await player.dispose();
    }
  }
}
