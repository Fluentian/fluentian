import 'package:flutter_test/flutter_test.dart';
import 'package:fluentian/core/app_localization.dart';

void main() {
  group('AppCopy', () {
    test('translates shared static navigation copy to Amharic', () {
      expect(AppCopy.translate('am', 'Settings'), 'ቅንብሮች');
      expect(AppCopy.translate('am', 'Sign in'), 'ግባ');
      expect(AppCopy.translate('am', 'Learn'), 'ተማር');
      expect(AppCopy.translate('am', 'Community'), 'ማህበረሰብ');
    });

    test('translates shared static navigation copy to Afaan Oromo', () {
      expect(AppCopy.translate('om', 'Settings'), 'Qindaa’inoota');
      expect(AppCopy.translate('om', 'Sign in'), 'Seeni');
      expect(AppCopy.translate('om', 'Learn'), 'Baradhu');
      expect(AppCopy.translate('om', 'Community'), 'Hawaasa');
    });

    test('localizes queued completion status', () {
      const pending = 'Saved offline — XP will update after sync';
      expect(AppCopy.translate('am', pending), isNot(pending));
      expect(AppCopy.translate('om', pending), isNot(pending));
    });

    test('localizes the speaking-room permission disclosure', () {
      const microphoneDisclosure =
          'Fluentian uses your microphone only while you are in this speaking room. Live audio is sent to the other participant through LiveKit and is not recorded by Fluentian.';
      expect(
        AppCopy.translate('am', 'Microphone access'),
        isNot('Microphone access'),
      );
      expect(
        AppCopy.translate('om', 'Microphone access'),
        isNot('Microphone access'),
      );
      expect(
        AppCopy.translate('am', microphoneDisclosure),
        isNot(microphoneDisclosure),
      );
      expect(
        AppCopy.translate('om', microphoneDisclosure),
        isNot(microphoneDisclosure),
      );
    });

    test('leaves dynamic server content unchanged', () {
      const courseTitle = 'French greetings for beginners';
      expect(AppCopy.translate('am', courseTitle), courseTitle);
      expect(AppCopy.translate('om', courseTitle), courseTitle);
    });
  });
}
