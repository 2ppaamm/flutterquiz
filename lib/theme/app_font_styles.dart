import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppFontStyles {
  static final heading1 = GoogleFonts.montserrat(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.3,
    letterSpacing: -1,
    color: AppColors.black,
  );

  static final heading2 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -1,
    color: AppColors.darkRed,
  );

  static final heading3 = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w500, // medium weight (not bold)
    color: AppColors.black,
  );
  static final heading4 = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w700, // medium weight (not bold)
    color: AppColors.darkRed,
    fontStyle: FontStyle.normal,
  );

  static final headingSubtitle = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w500, // medium weight (not bold)
    color: AppColors.black,
    fontStyle: FontStyle.normal,
  );

  static final tileText = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -1,
    color: AppColors.darkGreyText,
  );
  
  static final questionText = GoogleFonts.montserrat(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static final inputPlaceholder = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.black,
    fontStyle: FontStyle.italic,
  );  
  
  static final inputPad = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    fontStyle: FontStyle.normal,
  );

  static final greeting = GoogleFonts.montserrat(
    fontSize: 25,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -1,
    color: AppColors.black,
    fontStyle: FontStyle.normal,
  );

  static final name = GoogleFonts.montserrat(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -1,
    color: AppColors.black,
  );

  static final buttonPrimary = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static final buttonSubtitle = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.white,
  );
  static final buttonSecondary = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static final buttonSecondarySubtitle = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.black,
  );
    static final buttonQuestion = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}