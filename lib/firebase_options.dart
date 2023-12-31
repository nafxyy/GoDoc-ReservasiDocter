// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAoIpcfSGYnFBnwHeBnuDb3i3Lw6usgWJc',
    appId: '1:1090091910614:web:1863417ee1475810f61077',
    messagingSenderId: '1090091910614',
    projectId: 'godoc-reservasidocter',
    authDomain: 'godoc-reservasidocter.firebaseapp.com',
    storageBucket: 'godoc-reservasidocter.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCaWyoGnKsC1ALsb9zHJnCA1mge-oSVjS8',
    appId: '1:1090091910614:android:2f4223a84893fbf9f61077',
    messagingSenderId: '1090091910614',
    projectId: 'godoc-reservasidocter',
    storageBucket: 'godoc-reservasidocter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsfal5GKJpcs93oB0y-fPuZfe6RDDTWhc',
    appId: '1:1090091910614:ios:5bdc9f22dd1a9979f61077',
    messagingSenderId: '1090091910614',
    projectId: 'godoc-reservasidocter',
    storageBucket: 'godoc-reservasidocter.appspot.com',
    iosBundleId: 'com.example.paMobile',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsfal5GKJpcs93oB0y-fPuZfe6RDDTWhc',
    appId: '1:1090091910614:ios:0adc414b51e33ce3f61077',
    messagingSenderId: '1090091910614',
    projectId: 'godoc-reservasidocter',
    storageBucket: 'godoc-reservasidocter.appspot.com',
    iosBundleId: 'com.example.paMobile.RunnerTests',
  );
}
