import 'package:flutter/material.dart';

class SubscriptionRenewScreen extends StatelessWidget {
  const SubscriptionRenewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Expired')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Your subscription has expired.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to your purchase/renewal flow
              },
              child: const Text('Renew Now'),
            ),
            TextButton(
              onPressed: () {
                // or logout and force re‑login
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
