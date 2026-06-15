import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/landing/presentation/pages/landing_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/document_analysis/presentation/providers/document_provider.dart';
import 'package:flutter_application_transparatech/core/utils/logger.dart';
import 'package:flutter_application_transparatech/core/config/build_config.dart';

import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_queue_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_notification_provider.dart';
import 'package:flutter_application_transparatech/features/dashboard/presentation/providers/student_notification_provider.dart';
import 'package:flutter_application_transparatech/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';

void main() {
  // Initialize logger and logging
  AppLogger.info('Starting Verifi Application', tag: 'main');
  AppLogger.info('Build Environment: ${BuildConfig.environment.name}', tag: 'main');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdminQueueProvider()),
        ChangeNotifierProvider(create: (_) => AdminNotificationProvider()),
        ChangeNotifierProvider(create: (_) => StudentNotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'VeriFi',
      debugShowCheckedModeBanner: false,
      theme: VeriFiTheme.lightTheme,
      darkTheme: VeriFiTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const AuthPage(),
      },
      // TODO: Setup proper routing with GoRouter or similar package
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.tryAutoSignIn();
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: VeriFiColors.primary,
          ),
        ),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isSignedIn) {
      final user = authProvider.currentUser;
      if (user?.roleId == 1) {
        return const AdminDashboardPage();
      } else {
        return const DashboardPage();
      }
    }

    return const LandingPage();
  }
}

