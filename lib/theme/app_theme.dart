import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_font_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.darkRed,
        onPrimary: AppColors.white,
        secondary: AppColors.pink,
        onSecondary: AppColors.black,
        background: AppColors.white,
        onBackground: AppColors.black,
        surface: AppColors.tileGrey,
        onSurface: AppColors.darkGreyText,
        error: Colors.red,
        onError: AppColors.white,
      ),
      textTheme: GoogleFonts.montserratTextTheme().copyWith(
        // Headings
        headlineLarge: AppFontStyles.heading1,         // 28px bold
        headlineMedium: AppFontStyles.heading2,        // 24px bold darkRed
        headlineSmall: AppFontStyles.heading3,         // 20px medium

        // Titles
        titleLarge: AppFontStyles.heading4,            // 18px bold darkRed
        titleMedium: AppFontStyles.headingSubtitle,    // 12px subtitle
        titleSmall: AppFontStyles.tileText,            // 14px tile text

        // Body text
        bodyLarge: AppFontStyles.questionText,         // 20px regular for questions
        bodyMedium: AppFontStyles.questionText,    // 16px italic placeholder
        bodySmall: AppFontStyles.buttonSubtitle,       // 12px button subtitles

        // Labels (used in buttons)
        labelLarge: AppFontStyles.buttonPrimary,       // 20px white
        labelMedium: AppFontStyles.buttonSecondary,    // 20px black
        labelSmall: AppFontStyles.buttonSecondarySubtitle, // 12px black subtitle

        // Optional: You can also assign `greeting` and `name`
        displayMedium: AppFontStyles.greeting,
        displayLarge: AppFontStyles.name,
      ),
    );
  }
}