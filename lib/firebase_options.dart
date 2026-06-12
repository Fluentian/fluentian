import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options are not configured for web. '
        'Provide web Firebase config before using Firebase on web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase options are not configured for iOS. '
          'Add GoogleService-Info.plist and iOS Firebase options first.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase options are not configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase options are not configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options are not configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPSL7iDJtmh38Tvs_zfG7EQznhniHrdXc',
    appId: '1:461458509107:android:399650f30b672d4e7b0246',
    messagingSenderId: '461458509107',
    projectId: 'fluentian-c8d03',
    storageBucket: 'fluentian-c8d03.firebasestorage.app',
    androidClientId: null,
  );
}
