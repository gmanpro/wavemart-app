import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// WaveMart Text Styles
/// Using Outfit for headings and Inter for body text
class AppTextStyles {
  AppTextStyles._();

  // Headings - Outfit Font
  static TextStyle get headline1 => GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.navy950,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get headline2 => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.navy950,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get headline3 => GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.navy950,
        height: 1.25,
      );

  static TextStyle get headline4 => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.navy950,
        height: 1.3,
      );

  static TextStyle get title => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy950,
        height: 1.35,
      );

  static TextStyle get titleSmall => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy950,
        height: 1.4,
      );

  // Body Text - Inter Font
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.zinc700,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.zinc600,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.zinc500,
        height: 1.5,
      );

  // Button Styles
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.8,
      );

  // Label Styles
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
        letterSpacing: 0.8,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy600,
        letterSpacing: 1.2,
      );

  // Caption/Helper Text
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.zinc500,
        height: 1.4,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy600,
        letterSpacing: 1.5,
      );

  // Price Display
  static TextStyle get priceLarge => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.emerald600,
        height: 1.2,
      );

  static TextStyle get priceMedium => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.emerald600,
        height: 1.3,
      );

  // Badge/Pill Text
  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      );

  // Navigation
  static TextStyle get navActive => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.wave600,
      );

  static TextStyle get navInactive => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.navy500,
      );

  // Helper method to create colored variants
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  static TextStyle withSize(TextStyle base, double size) {
    return base.copyWith(fontSize: size);
  }

  static TextStyle bold(TextStyle base) {
    return base.copyWith(fontWeight: FontWeight.bold);
  }
}
