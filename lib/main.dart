import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/otp_login_screen.dart';
import 'presentation/screens/navigation/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers for crash logging
  FlutterError.onError = (details) {
    log('Flutter Error: ${details.exceptionAsString()}', name: 'WaveMart');
    if (kReleaseMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log('Platform Error: $error\nStack: $stack', name: 'WaveMart');
    return true;
  };

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const WaveMartApp());
}

class WaveMartApp extends StatelessWidget {
  const WaveMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Routes
      initialRoute: '/login',
      onGenerateRoute: _generateRoute,

      // Localizations will be added later
      locale: const Locale('en'),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _buildRoute(const OtpLoginScreen(), settings);
      case '/home':
      case '/':
        return _buildRoute(const MainNavigationShell(), settings);
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Page not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  PageRouteBuilder<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
