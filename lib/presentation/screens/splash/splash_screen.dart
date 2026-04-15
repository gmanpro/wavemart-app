import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../auth/otp_login_screen.dart';
import '../navigation/main_navigation_shell.dart';
import '../../widgets/common/app_logo.dart';

/// Modern Splash Screen displayed on app start
/// Performs auth check during display, then navigates to appropriate screen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app: check auth during splash display, then navigate
  Future<void> _initializeApp() async {
    // Minimum splash display time
    final minSplashTime = Future.delayed(const Duration(milliseconds: 1500));

    // Check local token in parallel
    final client = ApiClient();
    final hasToken = await client.isAuthenticated();

    // If token exists, verify with API in background
    if (hasToken) {
      // Don't await - let it run in background
      ref.read(authStateProvider.notifier).checkAuth();
    }

    // Wait for minimum splash time
    await minSplashTime;

    if (!mounted) return;

    // Decide where to navigate
    // If we have a local token, go to home (API verification happens in background)
    // If API returns 401 later, the app will redirect to login
    if (hasToken) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A416B),
              Color(0xFF0A355C),
              Color(0xFF18996C),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 800),
                  child: const GlassLogoContainer(size: 100, logoSize: 70),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'WaveMart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ethiopia\'s Premier Real Estate Marketplace',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16b364)),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
