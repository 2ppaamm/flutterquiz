import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'screens/auth/otp_request_screen.dart';
import 'screens/bottom_nav_screen.dart';
import 'screens/subject_select_screen.dart';
import 'screens/pre_user_info_screen.dart';
import 'screens/splash_screen.dart'; // For new user splash (octo.json)
import 'screens/startup_splash_screen.dart'; // For startup splash (octo2.json)
import 'package:flutter_stripe/flutter_stripe.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> _getInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final firstName = prefs.getString('first_name');
    final dob = prefs.getString('dob');
    final contact = prefs.getString('contact');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    bool isNewUser = (!isLoggedIn || token == null);
    Widget nextScreen;

    if (isLoggedIn && token != null) {
      if (firstName == null || firstName.isEmpty || dob == null || dob.isEmpty) {
        nextScreen = PreUserInfoScreen(contact: contact ?? '');
      } else {
        nextScreen = const BottomNavScreen();
      }
    } else {
      nextScreen = const OTPRequestScreen();
    }

    return {
      'isNewUser': isNewUser,
      'nextScreen': nextScreen,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Gifted Math',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<Map<String, dynamic>>(
        future: _getInitialData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final isNewUser = snapshot.data!['isNewUser'] as bool;
          final nextScreen = snapshot.data!['nextScreen'] as Widget;

          return isNewUser
              ? SplashScreen(nextScreen: nextScreen) // octo.json
              : StartupSplashScreen(nextScreen: nextScreen); // octo2.json
        },
      ),
      routes: {
        '/subject-select': (_) => SubjectSelectScreen(),
      },
    );
  }
}
