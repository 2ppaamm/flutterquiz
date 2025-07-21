import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pre_user_info_screen.dart';
import '../../theme/app_button_styles.dart';
import '../../theme/app_input_styles.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_font_styles.dart';
import '../../config.dart';
import 'dart:ui_web' as ui; // for platformViewRegistry
import 'dart:html' as html; // for ImageElement

class OTPRequestScreen extends StatefulWidget {
  const OTPRequestScreen({Key? key}) : super(key: key);

  @override
  _OTPRequestScreenState createState() => _OTPRequestScreenState();
}

class _OTPRequestScreenState extends State<OTPRequestScreen> {
  final _contactController = TextEditingController();
  final _otpController = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String? _contactError;

  @override
  void initState() {
    super.initState();

    // Register external image only once
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
    final ok = await AuthService.sendOTP(contact);
    setState(() {
      _loading = false;
      _sent = ok;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) return;
    setState(() => _loading = true);
    final result = await AuthService.verifyOTP(
      _contactController.text,
      _otpController.text,
    );
    setState(() => _loading = false);

    if (result != null) {
      final token = result['token'] as String;
      final firstName = result['first_name']?.toString() ?? '';
      final dob = result['dob']?.toString() ?? '';
      final isSubscriber = result['is_subscriber'] as bool? ?? false;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('auth_token', token);
      await prefs.setString('first_name', firstName);
      await prefs.setBool('is_subscriber', isSubscriber);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('contact', _contactController.text);

      if (firstName.isEmpty || dob.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PreUserInfoScreen(contact: _contactController.text),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const BottomNavScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired OTP')),
      );
    }
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
              Text('Log in or Sign Up', style: AppFontStyles.heading2),
              const SizedBox(height: 24),
              TextField(
                controller: _contactController,
                keyboardType: TextInputType.emailAddress,
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
                  decoration: AppInputStyles.general('Enter OTP'),
                ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF960000)),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sent ? _verifyOTP : _sendOTP,
                        style: AppButtonStyles.primary,
                        child: Text(
                          _sent ? 'Verify & Continue' : 'Send OTP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
