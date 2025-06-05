import 'package:flutter/material.dart';

import 'pages/login.dart';
import 'pages/sign-up.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF2F5233,
          const <int, Color>{
            50: Color(0xFFE8ECE9),
            100: Color(0xFFC5D0C8),
            200: Color(0xFF9FB1A3),
            300: Color(0xFF79927E),
            400: Color(0xFF5C7A63),
            500: Color(0xFF2F5233), // Couleur principale
            600: Color(0xFF2A4A2E),
            700: Color(0xFF244027),
            800: Color(0xFF1E3620),
            900: Color(0xFF152614),
          },
        ),
        // Configuration de la police Jost comme police par défaut
        fontFamily: 'Jost',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.w500),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}