import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/otp_login_screen.dart';
import 'presentation/screens/navigation/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    // Check auth status on app start (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).checkAuth().then((_) {
        if (mounted) {
          setState(() => _isCheckingAuth = false);
        }
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

    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.isAuthenticated
          ? const MainNavigationShell()
          : const OtpLoginScreen(),
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
