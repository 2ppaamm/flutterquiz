import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../bottom_nav_screen.dart';
import '../pre_user_info_screen.dart';

import '../../theme/app_button_styles.dart';
import '../../theme/app_input_styles.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_font_styles.dart';
import '../../config.dart';
import '../../services/auth_service.dart';

import 'dart:ui_web' as ui;
import 'dart:html' as html;

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
  bool _isEmailVerification = false;

  @override
  void initState() {
    super.initState();

    if (widget.prefilledEmail != null) {
      _contactController.text = widget.prefilledEmail!;
      _sent = widget.showOTPField;
      _isEmailVerification = widget.showOTPField;
    }

    // Logo/web image
    // ignore: undefined_prefixed_name
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
      setState(() => _contactError =
          'Enter a valid email or phone number with country code');
      return;
    }

    setState(() {
      _loading = true;
      _contactError = null;
    });

    try {
      final resp = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contact': contact}),
      );

      setState(() => _loading = false);
      final Map<String, dynamic> body = resp.body.isNotEmpty
          ? (jsonDecode(resp.body) as Map<String, dynamic>)
          : <String, dynamic>{};

      if (resp.statusCode == 200) {
        // Save user_id if backend returned it
        if (body['user_id'] != null) {
          final raw = body['user_id'];
          final id = (raw is int) ? raw : int.tryParse(raw.toString());
          if (id != null) {
            _userId = id;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', id);
          }
        }

        // Existing user flow → show OTP input
        if (body['email_hint'] != null || body['phone_hint'] != null) {
          setState(() {
            _sent = true;
            _isEmailVerification = false;
          });
          final hint = body['email_hint'] ?? body['phone_hint'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent to $hint'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // New user flow → go to pre-user screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PreUserInfoScreen(
                contact: contact,
                userId: _userId,
              ),
            ),
          );
        }
      } else if (resp.statusCode == 422) {
        // Legacy profile completion handling
        if (body['requires_profile_completion'] == true) {
          final raw = body['user_id'];
          final id = (raw is int) ? raw : int.tryParse(raw?.toString() ?? '');
          if (id != null) {
            _userId = id;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('user_id', id);
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PreUserInfoScreen(
                contact: contact,
                userId: _userId,
              ),
            ),
          );
          return;
        }

        setState(() =>
            _contactError = body['message'] ?? 'Invalid contact information');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                body['message'] ?? 'Failed to send OTP. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Network error. Please check your connection.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid 6-digit code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final contact = _contactController.text.trim();

      print('🔐 Verifying OTP for: $contact');

      final resp = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'contact': contact,
          'otp_code': otp,
        }),
      );

      print('📥 OTP Response: ${resp.statusCode}');
      print('📥 Response body: ${resp.body}');

      setState(() => _loading = false);
      final Map<String, dynamic> body = resp.body.isNotEmpty
          ? (jsonDecode(resp.body) as Map<String, dynamic>)
          : <String, dynamic>{};

      if (resp.statusCode == 200) {
        // Save token using AuthService
        if (body['token'] != null) {
          print('✅ Token received: ${body['token'].substring(0, 20)}...');
          await AuthService.saveToken(body['token']);
          print('✅ Token saved to SharedPreferences');

          // Verify it was saved
          final savedToken = await AuthService.getToken();
          print(
              '✅ Verified token in storage: ${savedToken?.substring(0, 20)}...');
        } else {
          print('⚠️ No token in response!');
        }

        // Save user info
        if (body['user_id'] != null) {
          final raw = body['user_id'];
          final id = (raw is int) ? raw : int.tryParse(raw.toString());
          if (id != null) {
            await AuthService.saveUserId(id);
            print('✅ User ID saved: $id');
          }
        }

        // Check if Kiasu is needed based on backend recommendation
        final kiasuRecommended = body['kiasu_recommended'] ?? false;
        print('🎯 Kiasu recommended: $kiasuRecommended');

        if (kiasuRecommended) {
          // Backend says we need Kiasu screen
          print('→ Navigating to PreUserInfoScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PreUserInfoScreen(
                contact: contact,
                userId: _userId,
              ),
            ),
          );
        } else {
          // Backend says skip Kiasu - mark as completed
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('kiasu_completed', true);
          print('→ Navigating to BottomNavScreen');

          // Go to main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomNavScreen()),
          );
        }
      } else {
        print('❌ OTP verification failed: ${resp.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Invalid OTP. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Network error. Please check your connection.'),
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
      return _isEmailVerification
          ? 'Enter the 6-digit code sent to your email to complete your account setup'
          : 'We sent a 6-digit login code to your email';
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
              Text(_getScreenTitle(), style: AppFontStyles.heading2),
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
                enabled: !_sent,
                decoration:
                    AppInputStyles.general('Email address or Phone').copyWith(
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
