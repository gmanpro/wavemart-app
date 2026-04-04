import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/otp_login_screen.dart';
import 'presentation/screens/navigation/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler for crash logging
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

  // Wrap with ProviderScope for Riverpod
  runApp(
    const ProviderScope(
      child: WaveMartApp(),
    ),
  );
}

class WaveMartApp extends ConsumerStatefulWidget {
  const WaveMartApp({super.key});

  @override
  ConsumerState<WaveMartApp> createState() => _WaveMartAppState();
}

class _WaveMartAppState extends ConsumerState<WaveMartApp> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    // Check auth status on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).checkAuth().then((_) {
        setState(() => _isCheckingAuth = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking auth
    if (_isCheckingAuth) {
      return MaterialApp(
        title: 'WaveMart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16B364)),
            ),
          ),
        ),
        locale: const Locale('en'),
      );
    }

    final authState = ref.watch(authStateProvider);
    
    // Determine initial route based on auth state
    final initialRoute = authState.isAuthenticated ? '/home' : '/login';

    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Routes - always start at root, navigation shell handles auth
      initialRoute: '/',
      onGenerateRoute: _generateRoute,
      builder: (context, child) {
        // Auth guard: redirect to login if not authenticated
        if (!authState.isAuthenticated && 
            ModalRoute.of(context)?.settings.name != '/login') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }
        return child!;
      },

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
          const Scaffold(
            body: Center(
              child: Text('Page not found'),
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
