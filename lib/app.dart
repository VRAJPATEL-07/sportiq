import 'package:flutter/material.dart';
import 'package:sportiq/core/constants/themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const Scaffold(),
    );
  }
}
