// lib/theme/app_input_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font_styles.dart';

class AppInputStyles {
  static final type2primary = InputDecoration(
    filled: true,
    fillColor: AppColors.lightGrey,
    hintText: 'Type your answer here',
    hintStyle: AppFontStyles.inputPlaceholder,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.56),
      borderSide: BorderSide(color: AppColors.tileGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.56),
      borderSide: BorderSide(color: AppColors.tileGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.56),
      borderSide: BorderSide(color: AppColors.darkGrey, width: 1),
    ),
  );

  static InputDecoration general(String label) => InputDecoration(
        labelText: label,
        labelStyle: AppFontStyles.inputPlaceholder,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.56),
          borderSide: BorderSide(color: AppColors.tileGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.56),
          borderSide: BorderSide(color: AppColors.tileGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.56),
          borderSide: BorderSide(color: AppColors.darkGrey),
        ),
      );

  static BoxDecoration type2Place({bool isActive = false}) {
    return BoxDecoration(
      color: isActive ? AppColors.gold : AppColors.tileGrey,
      borderRadius: BorderRadius.circular(8.56),
      border: Border.all(
        color: isActive ? Colors.orange : Colors.grey,
        width: 1.5,
      ),
    );
  }
}
