import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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

class GlassLogoContainer extends StatelessWidget {
  final double size;
  final double logoSize;

  const GlassLogoContainer({
    super.key,
    this.size = 100,
    this.logoSize = 70,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.wave500.withOpacity(0.35),
                AppColors.emerald500.withOpacity(0.25),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.wave500.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: AppLogo(size: logoSize),
          ),
        ),
      ),
    );
  }
}
