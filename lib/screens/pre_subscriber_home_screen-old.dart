import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_selection_screen.dart';

class PreSubscriberHomeScreen extends StatefulWidget {
  final String contact;

  const PreSubscriberHomeScreen({required this.contact});

  @override
  _PreSubscriberHomeScreenState createState() => _PreSubscriberHomeScreenState();
}

class _PreSubscriberHomeScreenState extends State<PreSubscriberHomeScreen> {
  String displayName = 'Visitor';

  @override
  void initState() {
    super.initState();
    _loadFirstName();
  }

  Future<void> _loadFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      displayName = prefs.getString('first_name') ?? 'Visitor';
    });
  }

  void _submitSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentSelectionScreen(),
      ),
    );
  }

  void _startDiagnostic() {
    print('🧪 Starting diagnostic test');
    // TODO: Call AuthService.startDiagnostic(...)
  }

  void _enterMastercode() {
    print('🔑 Mastercode entry flow');
    // TODO: Show dialog for entering mastercode
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FDF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.stars, color: Color(0xFF960000)),
                  const SizedBox(width: 4),
                  Text("0", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Center(child: Image.asset('assets/character1.png', width: 160)),
              const SizedBox(height: 20),
              Text('Welcome, $displayName!',
                  style: TextStyle(fontSize: 22, color: Colors.black87)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitSubscription,
                  child: const Text("Subscribe",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD5C2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _startDiagnostic,
                  child: const Text("Take Diagnostic Test",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE4B5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _enterMastercode,
                  child: const Text("Enter Mastercode",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
