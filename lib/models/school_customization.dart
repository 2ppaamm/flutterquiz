import 'package:flutter/material.dart';

class SchoolCustomization {
  final String schoolId;
  final String schoolName;
  final String? logoUrl;
  final CustomColors colors;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  SchoolCustomization({
    required this.schoolId,
    required this.schoolName,
    this.logoUrl,
    required this.colors,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });
  
  factory SchoolCustomization.fromJson(Map<String, dynamic> json) {
    return SchoolCustomization(
      schoolId: json['school_id'],
      schoolName: json['school_name'],
      logoUrl: json['logo_url'],
      colors: CustomColors.fromJson(json['colors']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'school_name': schoolName,
      'logo_url': logoUrl,
      'colors': colors.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

class CustomColors {
  final String primary;
  final String secondary;
  final String accent;
  final String textPrimary;
  final String background;
  
  CustomColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    this.textPrimary = '#000000',
    this.background = '#FFFFFF',
  });
  
  Color get primaryColor => _hexToColor(primary);
  Color get secondaryColor => _hexToColor(secondary);
  Color get accentColor => _hexToColor(accent);
  Color get textPrimaryColor => _hexToColor(textPrimary);
  Color get backgroundColor => _hexToColor(background);
  
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
  
  factory CustomColors.fromJson(Map<String, dynamic> json) {
    return CustomColors(
      primary: json['primary'],
      secondary: json['secondary'],
      accent: json['accent'],
      textPrimary: json['text_primary'] ?? '#000000',
      background: json['background'] ?? '#FFFFFF',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'text_primary': textPrimary,
      'background': background,
    };
  }
}