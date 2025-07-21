import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bottom_nav_screen.dart';
import '../config.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_input_styles.dart';
import '../theme/app_colors.dart';

class PreUserInfoScreen extends StatefulWidget {
  final String contact;

  const PreUserInfoScreen({Key? key, required this.contact}) : super(key: key);

  @override
  State<PreUserInfoScreen> createState() => _PreUserInfoScreenState();
}

class _PreUserInfoScreenState extends State<PreUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _submitUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session error. Please log in again.')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('${AppConfig.apiBaseUrl}/api/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstname': _nameController.text.trim(),
        'date_of_birth': _dobController.text.trim(),
      }),
    );

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      await prefs.setString('first_name', _nameController.text.trim());
      await prefs.setString('dob', _dobController.text.trim());

      final isSubscriber = prefs.getBool('is_subscriber') ?? false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save info. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Center(child: Image.asset('assets/logo.png', height: 100)),
                const SizedBox(height: 24),
                const Text(
                  "Let’s personalize your journey!",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: AppInputStyles.general('First Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration:  AppInputStyles.general('Date of Birth (YYYY-MM-DD)'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _submitUserInfo,
                  style: AppButtonStyles.primary,
                  child: _loading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
