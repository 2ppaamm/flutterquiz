import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth/otp_request_screen.dart';
import '../config.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_input_styles.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

class PreUserInfoScreen extends StatefulWidget {
  final String contact;
  final int? userId;
  final bool isNewUser;

  const PreUserInfoScreen({
    Key? key,
    required this.contact,
    this.userId,
    this.isNewUser = false,
  }) : super(key: key);

  @override
  State<PreUserInfoScreen> createState() => _PreUserInfoScreenState();
}

class _PreUserInfoScreenState extends State<PreUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _loading = false;
  bool _isPhoneContact = false;

  @override
  void initState() {
    super.initState();
    _isPhoneContact = !_isEmail(widget.contact);

    // Pre-fill the appropriate field based on contact type
    if (_isPhoneContact) {
      _phoneController.text = widget.contact;
    } else {
      _emailController.text = widget.contact;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  bool _isEmail(String input) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
        r"(?:\.[a-zA-Z]{2,})+$");
    return emailRegex.hasMatch(input);
  }

  Future<void> _submitUserInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      await _completeRegistration();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _completeRegistration() async {
    // Get user_id from either widget parameter or shared preferences
    int? userId = widget.userId;
    if (userId == null) {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id');
    }

    if (userId == null) {
      throw Exception('User ID not found. Please start over.');
    }

    final requestBody = {
      'user_id': userId,
      'phone_number': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'firstname': _firstNameController.text.trim(),
      'lastname': _lastNameController.text.trim(),
      'date_of_birth': _dobController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/complete-registration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      setState(() => _loading = false);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', _firstNameController.text.trim());
        await prefs.setString('email', _emailController.text.trim());

        // Handle partner upgrade response
        if (responseBody['partner_upgraded'] == true) {
          final partnerName = responseBody['partner_name'];
          await prefs.setBool('is_partner_user', true);
          await prefs.setString('partner_name', partnerName ?? '');

          // Show partner upgrade dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Expanded(child: Text('Premium Access!')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You have $partnerName premium access!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 16),
                  Text('Your Benefits:', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...List<String>.from(responseBody['benefits'] ?? [])
                      .map((benefit) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, 
                                 color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(benefit, style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      )).toList(),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, 
                             color: Colors.orange.shade700, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Please verify your email to complete setup',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to OTP verification with email prefilled
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OTPRequestScreen(
                          prefilledEmail: _emailController.text.trim(),
                          showOTPField: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Verify Email'),
                ),
              ],
            ),
          );
        } else {
          // Free user - show simple success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration complete! Please verify your email to start learning.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
          
          // Navigate to OTP verification with email prefilled
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OTPRequestScreen(
                prefilledEmail: _emailController.text.trim(),
                showOTPField: true,
              ),
            ),
          );
        }
      } else {
        // Handle registration errors
        String errorMessage = responseBody['message'] ?? 'Registration failed. Please try again.';
        
        if (responseBody['duplicate_email'] == true) {
          errorMessage = 'This email is already registered. Please use a different email or login with your existing account.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Date of birth is required';

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Please use YYYY-MM-DD format';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();
      if (date.isAfter(now)) {
        return 'Date cannot be in the future';
      }
      if (now.difference(date).inDays < 365) {
        return 'Must be at least 1 year old';
      }
    } catch (e) {
      return 'Invalid date format';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_isEmail(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number with country code (e.g., +6591234567)';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length < 2) return 'Must be at least 2 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.darkRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: 50,
                          color: AppColors.darkRed,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.isNewUser
                            ? "Welcome! Let's set up your account"
                            : "Complete your profile",
                        style: AppFontStyles.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contact: ${widget.contact}',
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          decoration: AppInputStyles.name('First Name'),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        TextFormField(
                          controller: _lastNameController,
                          decoration: AppInputStyles.name('Last Name'),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 16),

                        // Email (always required)
                        TextFormField(
                          controller: _emailController,
                          decoration: AppInputStyles.email(),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Phone Number (always required)
                        TextFormField(
                          controller: _phoneController,
                          decoration: AppInputStyles.phone(),
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        TextFormField(
                          controller: _dobController,
                          decoration: AppInputStyles.date(),
                          keyboardType: TextInputType.datetime,
                          validator: _validateDate,
                        ),

                        const SizedBox(height: 24),

                        // Info text
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.darkRed.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.darkRed,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'We need both your email and phone number to check for premium access eligibility and account security.',
                                  style: AppFontStyles.caption.copyWith(
                                    color: AppColors.darkRed,
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

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitUserInfo,
                    style: AppButtonStyles.primary,
                    child: _loading
                        ? CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            'Complete Registration',
                            style: AppFontStyles.buttonPrimary,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}