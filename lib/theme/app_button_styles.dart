import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font_styles.dart';

class AppButtonStyles {
  // ✅ Base shared style
  static final _base = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(56), // Fixed height for general buttons
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: AppFontStyles.buttonPrimary,
  );

  // 🔴 Primary: Red
  static final primary = _base.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.darkRed),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );

  // 🟧 Secondary: Peach
  static final secondary = _base.copyWith(
    backgroundColor: WidgetStateProperty.all(const Color(0xFFFFD5C2)),
    foregroundColor: WidgetStateProperty.all(Colors.black),
  );

  // 🟨 Tertiary: Light Yellow
  static final tertiary = _base.copyWith(
    backgroundColor: WidgetStateProperty.all(const Color(0xFFFFE4B5)),
    foregroundColor: WidgetStateProperty.all(Colors.black),
  );

  // ✅ Smaller base for question buttons
  static final _questionBase = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(48), // Smaller height
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.56),
    ),
    textStyle: AppFontStyles.buttonQuestion,
  );

  // Main submit button
  
  static final questionPrimary = _questionBase.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.darkRed),
    foregroundColor: WidgetStateProperty.all(AppColors.white),
  );

  static final questionCorrect = _questionBase.copyWith(
    backgroundColor:
        WidgetStateProperty.all(const Color(0xFF50D200)), // green
    foregroundColor: WidgetStateProperty.all(AppColors.white),
  );

  static final questionTryAgain = _questionBase.copyWith(
    backgroundColor: WidgetStateProperty.all(const Color(0xFFD80000)), // red
    foregroundColor: WidgetStateProperty.all(AppColors.white),
  );

  static final questionSkip = _questionBase.copyWith(
    backgroundColor:
        WidgetStateProperty.all(const Color(0xFFFFC0AB)), // peach
    foregroundColor: WidgetStateProperty.all(AppColors.black),
  );

  static final questionNext = _questionBase.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.darkRed),
    foregroundColor: WidgetStateProperty.all(AppColors.white),
  );

  static final numInputButton = _questionBase.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.lightGreyBackground),
    foregroundColor: WidgetStateProperty.all(AppColors.white),
  );
}
