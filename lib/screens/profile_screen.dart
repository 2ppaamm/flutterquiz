import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? firstName;
  String? contact;
  String? dob;
  bool isSubscriber = false;
  int maxileLevel = 0;
  int lexileLevel = 0;
  int lives = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name') ?? 'Student';
      contact = prefs.getString('contact') ?? '';
      dob = prefs.getString('dob') ?? '';
      isSubscriber = prefs.getBool('is_subscriber') ?? false;
      maxileLevel = prefs.getInt('maxile_level') ?? 0;
      lexileLevel = prefs.getInt('lexile_level') ?? 0;
      lives = prefs.getInt('lives') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $firstName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Contact: $contact', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Date of Birth: $dob', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Subscriber: ${isSubscriber ? "Yes" : "No"}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Maxile Level: $maxileLevel',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Lexile Level: $lexileLevel',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Lives: $lives', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
