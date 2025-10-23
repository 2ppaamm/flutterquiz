import 'package:flutter/material.dart';

class AppColors {
  static const Color lightGreyBackground = Color(0xFFeeeeee);
  static const Color tileGrey = Color(0xFFD9D9D9);
  static const Color darkRed = Color(0xFF960000);
  static const Color maroon = Color(0xFF853030);
  static const Color darkGreyText = Color(0xFF6D6D6D);
  static const Color lightGrey = Color(0xFFEdeded);
  static const Color black = Color(0xFF282828);
  static const Color pink = Color(0xFFD0ACAC);
  static const Color yellow = Color(0xFFFFBF66);
  static const Color gold = Color(0xFFFFBF66);
  static const Color white = Color(0xfffefefe);
  static const Color darkGrey = Color(0xFF5E5E5E);
  static const Color mediumGrey = Color(0xFFCCCCCC);
  static const Color darkText = Color(0xFF333333);

  // Success/Error states
  static const Color success = Color(0xFF388E3C);
  static const Color error = Color(0xFFD80000);

  // Input field states
  static const Color inputActive = Color(0xFF960000);
  static const Color inputInactive = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF8FAFC);

  // Progress indicators
  static const Color progressComplete = Color(0xFF2E7D32);
  static const Color progressActive = Color(0xFF960000);
  static const Color progressInactive = Color(0xFFD1D5DB);

  // Level progression colors (for diagnostic results)
  static const Color levelBeginner = Color(0xFF2196F3); // Blue
  static const Color levelBuilding = Color(0xFFFF9800); // Orange
  static const Color levelGrowing = Color(0xFF4CAF50); // Green
  static const Color levelAdvanced = Color(0xFF9C27B0); // Purple

  static const Color speedBlue = Color(0xFF2196F3); // Blue for speed
  static const Color accuracyGreen = Color(0xFF4CAF50); // Green for accuracy
  Color _getStatColor(String type) {
    switch (type) {
      case 'kudos':
        return AppColors.gold;
      case 'speed':
        return AppColors.speedBlue; // Using blue for speed
      case 'accuracy':
        return AppColors.accuracyGreen;
      case 'maxile':
        return AppColors.darkRed;
      default:
        return AppColors.darkRed;
    }
  }
}
