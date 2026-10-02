import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA8B7C6D5E4F3G2H1J0K9L8M7N6P5Q4R3S',
    appId: '1:452764973027:web:9c84e1b827e4fa10b981cd',
    messagingSenderId: '452764973027',
    projectId: 'om-1305',
    authDomain: 'om-1305.firebaseapp.com',
    storageBucket: 'om-1305.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8B7C6D5E4F3G2H1J0K9L8M7N6P5Q4R3S',
    appId: '1:452764973027:android:8f7e6d5c4b3a2109876543',
    messagingSenderId: '452764973027',
    projectId: 'om-1305',
    storageBucket: 'om-1305.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8B7C6D5E4F3G2H1J0K9L8M7N6P5Q4R3S',
    appId: '1:452764973027:ios:1a2b3c4d5e6f7g8h9i0jkl',
    messagingSenderId: '452764973027',
    projectId: 'om-1305',
    storageBucket: 'om-1305.appspot.com',
    iosBundleId: 'com.smarttrading.sim',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA8B7C6D5E4F3G2H1J0K9L8M7N6P5Q4R3S',
    appId: '1:452764973027:ios:1a2b3c4d5e6f7g8h9i0jkl',
    messagingSenderId: '452764973027',
    projectId: 'om-1305',
    storageBucket: 'om-1305.appspot.com',
    iosBundleId: 'com.smarttrading.sim',
  );
}
