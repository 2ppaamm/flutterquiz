import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/otp_request_screen.dart';
import 'screens/subject_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final firstName = prefs.getString('first_name');
  final contact = prefs.getString('contact');
  final isSubscriber = prefs.getBool('is_subscriber') ?? false;

  runApp(MyApp(
    token: token,
    firstName: firstName,
    contact: contact,
    isSubscriber: isSubscriber,
  ));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? firstName;
  final String? contact;
  final bool isSubscriber;

  const MyApp({
    required this.token,
    required this.firstName,
    required this.contact,
    required this.isSubscriber,
  });

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;

    if (token != null) {
      initialScreen = isSubscriber
          ? SubscriberHomeScreen(firstName: firstName ?? 'User', token: token!)
          : PreSubscriberHomeScreen(contact: contact ?? '');
    } else {
      initialScreen = OTPRequestScreen();
    }

    return MaterialApp(
      title: 'All Gifted Math',
      debugShowCheckedModeBanner: false,
      home: initialScreen,
      routes: {
        '/subject-select': (_) => SubjectSelectScreen(),
      },
    );
  }
}