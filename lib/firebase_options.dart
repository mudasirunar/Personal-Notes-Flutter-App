// File generated for Firebase configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured for this project.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcyufE-OlcqysRpJQzTVFOMTdfT0on0pE',
    appId: '1:154433975123:android:edbed63c3e990c83b7a7a6',
    messagingSenderId: '154433975123',
    projectId: 'personal-notes-app-30e1a',
    storageBucket: 'personal-notes-app-30e1a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbBqpwFkQ93aImQq3MJ-BHpe5Be05Y9js',
    appId: '1:154433975123:ios:98426d8b7a52289db7a7a6',
    messagingSenderId: '154433975123',
    projectId: 'personal-notes-app-30e1a',
    storageBucket: 'personal-notes-app-30e1a.firebasestorage.app',
    iosBundleId: 'com.mudasir.personalnotes',
  );
}
