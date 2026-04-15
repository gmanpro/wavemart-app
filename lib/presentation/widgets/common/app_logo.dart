import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Shared app logo widget using the actual app launcher icon
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.wave500, AppColors.emerald500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: size * 0.2,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.18),
        child: Image.asset(
          'assets/images/app_icon.png',
          fit: BoxFit.contain,
          color: Colors.white,
        ),
      ),
    );
  }
}
