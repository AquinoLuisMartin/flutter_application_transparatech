import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/landing/presentation/pages/landing_page.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'core/utils/logger.dart';
import 'core/config/build_config.dart';

void main() {
  // Initialize logger and logging
  AppLogger.info('Starting Verifi Application', tag: 'main');
  AppLogger.info('Build Environment: ${BuildConfig.environment.name}', tag: 'main');
  
  // TODO: Initialize dependency injection container
  // await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verifi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const LandingPage(),
      routes: {
        '/login': (context) => const AuthPage(),
      },
      // TODO: Setup proper routing with GoRouter or similar package
    );
  }
}
