// Placeholder Firebase configuration file.
// Replace these values by running the FlutterFire CLI (`flutterfire configure`) or
// by providing real Firebase config values for each platform.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (Platform.isAndroid) return android;
    if (Platform.isIOS || Platform.isMacOS) return ios;
    if (Platform.isWindows) return windows;
    return android;
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
