import 'package:flutter/material.dart';
import '../bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pre_user_info_screen.dart';
import '../../theme/app_button_styles.dart';
import '../../theme/app_input_styles.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_font_styles.dart';
import '../../config.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

class OTPRequestScreen extends StatefulWidget {
  final String? prefilledEmail;
  final bool showOTPField;
  
  const OTPRequestScreen({
    Key? key, 
    this.prefilledEmail,
    this.showOTPField = false,
  }) : super(key: key);

  @override
  _OTPRequestScreenState createState() => _OTPRequestScreenState();
}

class _OTPRequestScreenState extends State<OTPRequestScreen> {
  final _contactController = TextEditingController();
  final _otpController = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _contactError;
  int? _userId;
  bool _isEmailVerification = false; // Track if this is email verification

  @override
  void initState() {
    super.initState();
    
    // Handle prefilled email and show OTP field immediately
    if (widget.prefilledEmail != null) {
      _contactController.text = widget.prefilledEmail!;
      _sent = widget.showOTPField;
      _isEmailVerification = widget.showOTPField; // Coming from registration
    }

    ui.platformViewRegistry.registerViewFactory(
      'externalImage',
      (int viewId) => html.ImageElement()
        ..src = '${AppConfig.apiBaseUrl}/images/houses/1548697074.png'
        ..style.width = '180px'
        ..style.height = '180px'
        ..style.objectFit = 'contain'
        ..alt = 'Logo',
    );
  }

  bool _isValidContact(String input) {
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
        r"(?:\.[a-zA-Z]{2,})+$");
    if (input.startsWith('+')) {
      return phoneRegex.hasMatch(input);
    } else {
      return emailRegex.hasMatch(input);
    }
  }

  Future<void> _sendOTP() async {
    final contact = _contactController.text.trim();
    if (!_isValidContact(contact)) {
      setState(() => _contactError = 'Enter a valid email or phone number with country code');
      return;
    }
    
    setState(() {
      _loading = true;
      _contactError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contact': contact,
        }),
      );

      setState(() => _loading = false);
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Store user_id for registration
        if (responseBody['user_id'] != null) {
          _userId = responseBody['user_id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', _userId!);
        }

        // Check if this is an existing user with OTP sent
        if (responseBody['email_hint'] != null) {
          setState(() {
            _sent = true;
            _isEmailVerification = false; // This is login OTP
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent to ${responseBody['email_hint']}'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // New user - redirect to registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PreUserInfoScreen(
                contact: contact,
                userId: _userId,
                isNewUser: true,
              ),
            ),
          );
        }
      } else if (response.statusCode == 422) {
        // Handle different 422 responses
        if (responseBody['requires_profile_completion'] == true) {
          _userId = responseBody['user_id'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', _userId!);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PreUserInfoScreen(
                contact: contact,
                userId: _userId,
                isNewUser: false,
              ),
            ),
          );
          return;
        } else if (responseBody['requires_email_verification'] == true) {
          // Show OTP field for email verification
          setState(() {
            _sent = true;
            _isEmailVerification = true; // This is email verification
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please verify your email to continue. Check your inbox for the verification code.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        } else {
          setState(() => _contactError = responseBody['message'] ?? 'Invalid contact information');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message'] ?? 'Failed to send OTP. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _loading = true);
    
    try {
      String endpoint;
      Map<String, String> body;
      
      // Determine which endpoint to use based on verification type
      if (_isEmailVerification) {
        // Email verification
        endpoint = '${AppConfig.apiBaseUrl}/api/auth/verify-email';
        body = {
          'email': _contactController.text.trim(),
          'verification_code': _otpController.text.trim(),
        };
      } else {
        // Login OTP verification  
        endpoint = '${AppConfig.apiBaseUrl}/api/auth/verify-otp';
        body = {
          'contact': _contactController.text.trim(),
          'otp_code': _otpController.text.trim(),
        };
      }
      
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      setState(() => _loading = false);
      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        
        if (_isEmailVerification) {
          // Email verification successful - get stored user data
          final firstName = prefs.getString('first_name') ?? '';
          final isPartnerUser = prefs.getBool('is_partner_user') ?? false;
          final partnerName = prefs.getString('partner_name');
          
          // Set login state
          await prefs.setBool('is_logged_in', true);
          
          // Show success message
          if (isPartnerUser && partnerName != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email verified! Welcome $partnerName user with premium access.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 4),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email verified successfully! Welcome to All Gifted Math.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Login verification successful - store user data from response
          final token = responseBody['token'] as String;
          final firstName = responseBody['first_name']?.toString() ?? '';
          final isPartnerUser = responseBody['is_partner_user'] as bool? ?? false;
          final partnerName = responseBody['partner_name']?.toString();
          final accessType = responseBody['access_type']?.toString() ?? 'free';
          
          await prefs.setString('auth_token', token);
          await prefs.setString('first_name', firstName);
          await prefs.setBool('is_partner_user', isPartnerUser);
          await prefs.setString('access_type', accessType);
          if (partnerName != null) {
            await prefs.setString('partner_name', partnerName);
          }
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('contact', _contactController.text);

          // Show partner welcome message if applicable
          if (isPartnerUser && partnerName != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome $partnerName user! You have premium access.'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
        
        // Navigate to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody['message'] ?? 'Invalid or expired OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getScreenTitle() {
    if (_sent) {
      return _isEmailVerification ? 'Verify Your Email' : 'Enter Login Code';
    }
    return 'Log in or Sign Up';
  }

  String _getSubtitle() {
    if (_sent) {
      if (_isEmailVerification) {
        return 'Enter the 6-digit code sent to your email to complete your account setup';
      } else {
        return 'We sent a 6-digit login code to your email';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 180,
                  child: HtmlElementView(viewType: 'externalImage'),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _getScreenTitle(), 
                style: AppFontStyles.heading2
              ),
              const SizedBox(height: 8),
              if (_sent)
                Text(
                  _getSubtitle(),
                  style: AppFontStyles.bodyMedium.copyWith(
                    color: AppColors.darkGreyText,
                  ),
                ),
              const SizedBox(height: 24),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.emailAddress,
                enabled: !_sent, // Disable editing when OTP is sent
                decoration: AppInputStyles.general('Email address or Phone').copyWith(
                  errorText: _contactError,
                ),
              ),
              const SizedBox(height: 16),
              if (_sent)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: AppInputStyles.general('Enter 6-digit code'),
                  autofocus: true,
                ),
              const SizedBox(height: 24),
              _loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sent ? _verifyOTP : _sendOTP,
                        style: AppButtonStyles.primary,
                        child: Text(
                          _sent ? 'Verify & Continue' : 'Send OTP',
                          style: AppFontStyles.buttonPrimary,
                        ),
                      ),
                    ),
              if (_sent) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _sent = false;
                        _otpController.clear();
                        _isEmailVerification = false;
                      });
                    },
                    child: Text(
                      'Change Email',
                      style: TextStyle(color: AppColors.darkRed),
                    ),
                  ),
                ),
                if (_isEmailVerification) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Didn\'t receive the email? Check your spam folder.',
                      style: AppFontStyles.caption.copyWith(
                        color: AppColors.darkGreyText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}