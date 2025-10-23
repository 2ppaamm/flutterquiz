import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../utils/smooth_page_transitions.dart';
import 'bottom_nav_screen.dart';
import '../services/diagnostic_service.dart';

class PreUserInfoScreen extends StatefulWidget {
  final String contact;
  final int? userId;

  const PreUserInfoScreen({
    Key? key,
    required this.contact,
    this.userId,
  }) : super(key: key);

  @override
  State<PreUserInfoScreen> createState() => _PreUserInfoScreenState();
}

class _PreUserInfoScreenState extends State<PreUserInfoScreen> {
  final _nameController = TextEditingController();
  String? _grade;
  bool _loading = false;

  static const _grades = [
    'PreNursery',
    'Nursery 1',
    'Nursery 2',
    'K1',
    'K2',
    'P1',
    'P2',
    'P3',
    'P4',
    'P5',
    'P6',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Method for Submit button
  Future<void> _onSubmit() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _loading = true);
    
    print('✅ Submit clicked');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Save first name
    await prefs.setString('first_name', _nameController.text.trim());
    
    // Save grade hint to backend if provided
    if (_grade != null) {
      print('📤 Saving grade hint: $_grade');
      final result = await DiagnosticService.storeHint({'grade': _grade});
      
      if (result == null || result['ok'] != true) {
        print('❌ Grade hint save failed');
        setState(() => _loading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save information. Please try again.')),
          );
        }
        return;
      }
      print('✅ Grade hint saved');
    } else {
      print('⏭️ No grade hint provided, skipping save');
    }
    
    // Mark kiasu as completed
    await prefs.setBool('kiasu_completed', true);
    
    if (!mounted) return;
    
    setState(() => _loading = false);
    
    // Navigate to main app home screen
    print('🚀 Navigating to Home Screen...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Fun header with Octo character
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkRed.withOpacity(0.05),
                      AppColors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Octo mascot placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.darkRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.smart_toy_outlined, size: 40, color: AppColors.darkRed),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kiasu Start! 🚀',
                      style: AppFontStyles.heading1.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help Octo find your perfect level',
                      style: AppFontStyles.bodyMedium.copyWith(color: AppColors.darkGreyText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tell us your name and grade - quick and easy!',
                      style: AppFontStyles.bodyMedium.copyWith(
                        color: AppColors.darkGreyText,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Input Field (Required)
                    Row(
                      children: [
                        Text(
                          'What should we call you?',
                          style: AppFontStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: AppFontStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        filled: true,
                        fillColor: AppColors.inputBackground,
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
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.darkRed),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 32),

                    // Grade Selector (Optional)
                    Text(
                      'What grade are you in? (optional)',
                      style: AppFontStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _grades.map((g) {
                        final isSelected = _grade == g;
                        return GestureDetector(
                          onTap: () => setState(() => _grade = isSelected ? null : g),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.darkRed : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.darkRed : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.darkRed.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              g,
                              style: AppFontStyles.bodyMedium.copyWith(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    if (_grade != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Tap again to deselect',
                        style: AppFontStyles.buttonSubtitle.copyWith(
                          color: AppColors.darkGreyText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onSubmit,
                        style: AppButtonStyles.primary,
                        child: _loading
                            ? CircularProgressIndicator(color: AppColors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Get Started', style: AppFontStyles.buttonPrimary),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20, color: AppColors.white),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}