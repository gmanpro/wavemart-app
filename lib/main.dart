import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/otp_login_screen.dart';
import 'presentation/screens/navigation/main_navigation_shell.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for draft persistence
  await Hive.initFlutter();
  await Hive.openBox('listing_drafts');

  // Disable google_fonts runtime fetching - fonts are bundled locally
  GoogleFonts.config.allowRuntimeFetching = false;

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
  bool _showHome = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app: show splash, check auth, then navigate
  Future<void> _initializeApp() async {
    // Show splash for a minimum duration
    final stopwatch = Stopwatch()..start();
    
    // Check local token in parallel with splash timer
    final client = ApiClient();
    final hasToken = await client.isAuthenticated();
    
    // Ensure minimum splash duration (1.5 seconds)
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }

    if (!mounted) return;

    if (hasToken) {
      // User has local token - show home immediately
      // Works offline with cached data
      setState(() {
        _showHome = true;
        _showSplash = false;
      });

      // Background API auth check — only redirect to login on explicit 401
      ref.read(authStateProvider.notifier).checkAuth().then((_) {
        if (mounted) {
          final authState = ref.read(authStateProvider);
          // Only switch to login if API explicitly rejected (401 cleared token)
          if (!authState.isAuthenticated && !authState.isLoading) {
            setState(() {
              _showHome = false;
              _showSplash = false;
            });
          }
        }
      });
    } else {
      // No local token - show login
      setState(() {
        _showHome = false;
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // When auth state changes to authenticated (e.g. after login), show home
    if (authState.isAuthenticated && !_showHome && !_showSplash) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showHome = true);
      });
    }

    // When auth state changes to unauthenticated and we had a token, show login
    if (!authState.isAuthenticated && !authState.isLoading && _showHome && !_showSplash) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showHome = false);
      });
    }

    // Build the appropriate screen
    Widget targetScreen;
    if (_showSplash) {
      targetScreen = const SplashScreen();
    } else if (_showHome) {
      targetScreen = const MainNavigationShell();
    } else {
      targetScreen = const OtpLoginScreen();
    }

    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: targetScreen,
      onGenerateRoute: _generateRoute,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return child;
      },
      locale: const Locale('en'),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case '/login':
        page = const OtpLoginScreen();
        break;
      case '/home':
      case '/':
        page = const MainNavigationShell();
        break;
      default:
        page = const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        );
    }
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
