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
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkLocalAuth();
  }

  /// Check local token to decide initial screen.
  /// If token exists locally, show home immediately (works offline with cached data).
  /// API auth check runs in background — only redirects to login on explicit 401.
  Future<void> _checkLocalAuth() async {
    final client = ApiClient();
    _hasToken = await client.isAuthenticated();

    if (mounted) {
      setState(() => _showHome = _hasToken);

      // Background API auth check — don't block UI
      if (_hasToken) {
        ref.read(authStateProvider.notifier).checkAuth().then((_) {
          if (mounted) {
            final authState = ref.read(authStateProvider);
            // Only switch to login if API explicitly rejected (401 cleared token)
            if (!authState.isAuthenticated && !authState.isLoading) {
              setState(() => _showHome = false);
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // When auth state changes to authenticated (e.g. after login), show home
    if (authState.isAuthenticated && !_showHome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showHome = true);
      });
    }

    // When auth state changes to unauthenticated and we had a token, show login
    if (!authState.isAuthenticated && !authState.isLoading && _showHome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _showHome = false);
      });
    }

    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showHome
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
