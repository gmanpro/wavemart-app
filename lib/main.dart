import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
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

class WaveMartApp extends StatelessWidget {
  const WaveMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaveMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return child;
      },
      locale: const Locale('en'),
    );
  }
}
