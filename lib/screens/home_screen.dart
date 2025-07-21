import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/otp_request_screen.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_font_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firstName = 'Student';
  String _token = '';
  bool _isSubscriber = false;
  int _gameLevel = 0;
  int _maxileLevel = 0;
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    loadFromStorage();
  }

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('first_name') ?? 'Student';
      _token = prefs.getString('auth_token') ?? '';
      _isSubscriber = prefs.getBool('is_subscriber') ?? false;
      _gameLevel = prefs.getInt('game_level') ?? 0;
      _maxileLevel = prefs.getInt('maxile_level') ?? 0;
      _lives = prefs.getInt('lives') ?? 3;
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OTPRequestScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFF960000)),
                      const SizedBox(width: 4),
                      Text(
                        "$_gameLevel",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.grey[700]),
                    tooltip: 'Logout',
                    onPressed: logout,
                  ),
                ],
              ),

              const SizedBox(height: 183),

              SizedBox(
                width: 200,
                height: 200,
                child: RiveAnimation.asset(
                  'rubick_hover.riv',
                  artboard: 'Main Art',
                  stateMachines: ['State Machine 1'],
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    final controller = StateMachineController.fromArtboard(
                      artboard,
                      'State Machine 1',
                    );
                    if (controller != null) {
                      artboard.addController(controller);
                      final input = controller.findInput<bool>('Boolean 1');
                      if (input is SMIBool) input.value = true;
                    }
                  },
                ),
              ),

              const SizedBox(height: 64),

              Text('Welcome back,', style: Theme.of(context).textTheme.displayMedium),
              Text('$_firstName!', style: Theme.of(context).textTheme.displayLarge),

              const SizedBox(height: 60),

              // 🔴 Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primary,
                  onPressed: () {},
                  child: Column(
                    children: [
                      Text("Continue", style: AppFontStyles.buttonPrimary),
                      Text("Start where you left off", style: AppFontStyles.buttonSubtitle),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🟧 Test Your Skills Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.secondary,
                  onPressed: () {},
                  child: Column(
                    children: [
                      Text("Test Your Skills", style: AppFontStyles.buttonSecondary),
                      Text("Diagnostic test", style: AppFontStyles.buttonSecondarySubtitle),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🟨 Subject Select Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.tertiary,
                  onPressed: () {
                    Navigator.pushNamed(context, '/subject-select');
                  },
                  child: Column(
                    children: [
                      Text("Subject Select", style: AppFontStyles.buttonSecondary),
                      Text("Practice any subject", style: AppFontStyles.buttonSecondarySubtitle),
                    ],
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