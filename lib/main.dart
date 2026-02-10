
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'auth/auth_service.dart';
import 'auth/auth_service_base.dart';
import 'providers/equipment_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  String? firebaseError;
  try {
    print('Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw FirebaseException(plugin: 'firebase_core', message: 'Firebase initialization timeout');
      }
    );
    print('Firebase initialization successful!');
    firebaseReady = true;
  } catch (e) {
    // capture the error and prevent falling back to insecure mock auth
    firebaseReady = false;
    firebaseError = e.toString();
    // ignore: avoid_print
    print('Firebase.initializeApp() error: $firebaseError');
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
  print('Starting SportiQ app...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<IAuthService>.value(
          value: AuthService.instance,
        ),
        ChangeNotifierProvider.value(
          value: EquipmentProvider.instance,
        ),
      ],
      child: const SportiQApp(),
    ),
  );
}
