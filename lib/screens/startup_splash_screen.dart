import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'auth/otp_request_screen.dart';
import 'bottom_nav_screen.dart';

class StartupSplashScreen extends StatefulWidget {
  const StartupSplashScreen({super.key});

  @override
  State<StartupSplashScreen> createState() => _StartupSplashScreenState();
}

class _StartupSplashScreenState extends State<StartupSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

Future<void> _initializeApp() async {
  // Show splash for branding
  await Future.delayed(const Duration(seconds: 2));
  
  if (!mounted) return;
  
  try {
    // Check for existing token
    final token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      // No token - go to login
      _navigateTo(const OTPRequestScreen());
      return;
    }
       
    // Has token - go to home
    _navigateTo(const BottomNavScreen());
    
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
    // On error, default to login for safety
    _navigateTo(const OTPRequestScreen());
  }
}
  void _navigateTo(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 100,
              color: Color(0xFF960000),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color(0xFF960000),
            ),
            const SizedBox(height: 16),
            Text(
              'All Gifted Math',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF960000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}