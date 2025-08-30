import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font_styles.dart';

class AppInputStyles {
  // Base input decoration
  static InputDecoration _baseDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputInactive),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputInactive),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.inputActive, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  // General input field style
  static InputDecoration general(String hintText) {
    return _baseDecoration().copyWith(
      hintText: hintText,
      hintStyle: AppFontStyles.bodyMedium.copyWith(
        color: AppColors.darkGreyText,
      ),
    );
  }

  // Email input style
  static InputDecoration email() {
    return general('Email address').copyWith(
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.darkGreyText),
    );
  }

  // Phone input style
  static InputDecoration phone() {
    return general('Phone number').copyWith(
      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.darkGreyText),
    );
  }

  // Password input style
  static InputDecoration password({bool obscureText = true}) {
    return general('Password').copyWith(
      prefixIcon: Icon(Icons.lock_outlined, color: AppColors.darkGreyText),
      suffixIcon: Icon(
        obscureText ? Icons.visibility_off : Icons.visibility,
        color: AppColors.darkGreyText,
      ),
    );
  }

  // OTP input style
  static InputDecoration otp() {
    return _baseDecoration().copyWith(
      hintText: 'Enter OTP',
      hintStyle: AppFontStyles.bodyMedium.copyWith(
        color: AppColors.darkGreyText,
      ),
      counterText: '',
    );
  }

  // Search input style
  static InputDecoration search(String hintText) {
    return _baseDecoration().copyWith(
      hintText: hintText,
      hintStyle: AppFontStyles.bodyMedium.copyWith(
        color: AppColors.darkGreyText,
      ),
      prefixIcon: Icon(Icons.search, color: AppColors.darkGreyText),
      fillColor: AppColors.white,
    );
  }

  // Date input style
  static InputDecoration date() {
    return general('Date of Birth (YYYY-MM-DD)').copyWith(
      prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.darkGreyText),
    );
  }

  // Name input style
  static InputDecoration name(String label) {
    return general(label).copyWith(
      prefixIcon: Icon(Icons.person_outlined, color: AppColors.darkGreyText),
    );
  }
}