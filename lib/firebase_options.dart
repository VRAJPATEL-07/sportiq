// Placeholder Firebase configuration file.
// This project strictly uses Firebase Spark Plan (Free Tier).
// No billing enabled. No paid services used.
// Replace these values by running the FlutterFire CLI (`flutterfire configure`) or
// by providing real Firebase config values for each platform.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS || TargetPlatform.macOS => ios,
      TargetPlatform.windows => windows,
      _ => android,
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVyd15alev6WudhDamrDrgV3czddGypPE',
    appId: '1:443453980990:android:1ec8b463d02c7d7a3d2c6f',
    messagingSenderId: '443453980990',
    projectId: 'sportiq-824eb',
    storageBucket: 'sportiq-824eb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVyd15alev6WudhDamrDrgV3czddGypPE',
    appId: '1:443453980990:ios:c8db69165a94ec733d2c6f',
    messagingSenderId: '443453980990',
    projectId: 'sportiq-824eb',
    storageBucket: 'sportiq-824eb.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBVyd15alev6WudhDamrDrgV3czddGypPE',
    appId: '1:443453980990:web:88f18f0d8644f6f33d2c6f',
    messagingSenderId: '443453980990',
    projectId: 'sportiq-824eb',
    authDomain: 'sportiq-824eb.firebaseapp.com',
    storageBucket: 'sportiq-824eb.appspot.com',
    measurementId: 'G-LVRQJKKQSX',
  );

  // Windows desktop configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBVyd15alev6WudhDamrDrgV3czddGypPE',
    appId: '1:443453980990:windows:aed17a17d08679e33d2c6f',
    messagingSenderId: '443453980990',
    projectId: 'sportiq-824eb',
    storageBucket: 'sportiq-824eb.appspot.com',
  );
}
