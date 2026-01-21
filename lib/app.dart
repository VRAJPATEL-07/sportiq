import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/splash_screen.dart';

class SportiQApp extends StatefulWidget {
  const SportiQApp({super.key});

  @override
  State<SportiQApp> createState() => _SportiQAppState();
}

class _SportiQAppState extends State<SportiQApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportiQ',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: SplashScreen(onToggleTheme: _toggleTheme),
    );
  }
}
