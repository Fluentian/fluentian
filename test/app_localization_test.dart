import 'package:flutter_test/flutter_test.dart';
import 'package:fluentian/core/app_localization.dart';

void main() {
  group('AppCopy', () {
    test('translates shared static navigation copy to Amharic', () {
      expect(AppCopy.translate('am', 'Settings'), 'ቅንብሮች');
      expect(AppCopy.translate('am', 'Sign in'), 'ግባ');
    });

    test('translates shared static navigation copy to Afaan Oromo', () {
      expect(AppCopy.translate('om', 'Settings'), 'Qindaa’inoota');
      expect(AppCopy.translate('om', 'Sign in'), 'Seeni');
    });

    test('leaves dynamic server content unchanged', () {
      const courseTitle = 'French greetings for beginners';
      expect(AppCopy.translate('am', courseTitle), courseTitle);
      expect(AppCopy.translate('om', courseTitle), courseTitle);
    });
  });
}
