import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime MT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}