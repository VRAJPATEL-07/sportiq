
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'auth/auth_service.dart';
import 'auth/auth_service_base.dart';
import 'providers/equipment_provider.dart';
import 'providers/notification_provider.dart';
import 'core/navigation.dart';
import 'services/notification_service.dart';
import 'services/local_notification_service.dart';
import 'providers/post_provider.dart';
import 'providers/image_files_provider.dart';

bool get _isMobileTarget {
  if (kIsWeb) return false;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('DEBUG_PROOF: main() entered');

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('DEBUG_PROOF: orientation lock configured');

  bool firebaseReady = false;
  String? firebaseError;
  try {
    debugPrint('Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw FirebaseException(plugin: 'firebase_core', message: 'Firebase initialization timeout');
      }
    );
    debugPrint('Firebase initialization successful!');
    firebaseReady = true;
  } catch (e) {
    // capture the error and prevent falling back to insecure mock auth
    firebaseReady = false;
    firebaseError = e.toString();
    // ignore: avoid_print
    debugPrint('Firebase.initializeApp() error: $firebaseError');
  }

  if (!firebaseReady) {
    // If Firebase isn't configured, run a small informative app that
    // shows the error and instructs the developer/user to configure Firebase.
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Not Configured')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Firebase Not Initialized',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('This app requires Firebase to be configured to use authentication.'),
              const SizedBox(height: 12),
              Text('Error: $firebaseError', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              const Text('To fix:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('1) Configure Firebase in the web console: https://console.firebase.google.com/'),
              const Text('2) Enable Email/Password Authentication'),
              const Text('3) Create Firestore Database'),
              const SizedBox(height: 8),
              const Text('See: https://firebase.flutter.dev/docs/overview'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => {},
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    ));
    return;
  }

  // Firebase initialized successfully -> run the real app with real providers
  debugPrint('Starting SportiQ app...');
  
  // Initialize local notifications (for static timer-based notifications)
  try {
    await LocalNotificationService.instance.initialize();
    debugPrint('DEBUG_PROOF: LocalNotificationService.initialize() completed');
    // Schedule demo periodic notification every 1 minute only on mobile platforms
    if (_isMobileTarget) {
      await LocalNotificationService.instance.schedulePeriodicNotification();
      debugPrint('DEBUG_PROOF: periodic local notification scheduled for mobile target');
    }
  } catch (e) {
    debugPrint('Warning: LocalNotificationService init failed: $e');
  }
  
  // Initialize Firebase notifications (Lab 8) and pass navigator key for tap navigation
  try {
    await NotificationService.instance.initialize(appNavigatorKey);
    debugPrint('DEBUG_PROOF: NotificationService.initialize() completed');
  } catch (e) {
    debugPrint('Warning: NotificationService init failed: $e');
  }

  debugPrint('DEBUG_PROOF: runApp() about to execute');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<IAuthService>.value(
          value: AuthService.instance,
        ),
        ChangeNotifierProvider.value(
          value: EquipmentProvider.instance,
        ),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ImageFilesProvider()),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            notificationService: LocalNotificationService.instance,
          ),
        ),
      ],
      child: const SportiQApp(),
    ),
  );
}
