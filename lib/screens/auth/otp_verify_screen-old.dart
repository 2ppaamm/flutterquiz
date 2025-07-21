import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String contact;

  OTPVerifyScreen({required this.contact});

  @override
  _OTPVerifyScreenState createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool isVerifying = false;

  Future<void> verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => isVerifying = true);
    final result = await AuthService.verifyOTP(widget.contact, otp);
    setState(() => isVerifying = false);

    if (result != null) {
      final token = result['token'] as String;
      final firstName = result['first_name']?.toString() ?? '';
      final dob = result['dob']?.toString() ?? '';
      final isSubscriber = result['is_subscriber'] as bool? ?? false;
      final maxileLevel = result['maxile_level'] as int ? ?? 0;
      final gameLevel = result['game_level'] as int? ?? 0;
      final lives = result['lives'] as int? ?? 5;

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
            builder: (_) => BottomNavScreen(
              firstName: firstName,
              token: token,
              isSubscriber: isSubscriber,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid or expired OTP")),
      );
    }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP sent to ${widget.contact}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                hintText: '6-digit OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isVerifying ? null : verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF960000),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: isVerifying
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Verify & Continue',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}