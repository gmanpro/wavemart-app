import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../widgets/common/app_logo.dart';

/// Modern Splash Screen displayed on app start
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy950,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const AppLogo(size: 120),
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
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.wave500),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
