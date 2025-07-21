import 'package:flutter/material.dart';
import '../../services/stripe_service.dart';

class PaymentSelectionScreen extends StatelessWidget {
  const PaymentSelectionScreen({super.key});

  void _selectPayment(BuildContext context, String method) {
    // TODO: Replace with real payment flow (Stripe, PayPal etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected $method (not implemented yet)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Payment Method"),
        backgroundColor: const Color(0xFF960000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _selectPayment(context, "Stripe"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text("Pay with Stripe"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectPayment(context, "PayPal"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text("Pay with PayPal"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
            onPressed: () async {
                try {
                await StripeService.startCheckoutSession();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Payment successful')),
                );
                } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Payment failed: $e')),
                );
                }
            },
            child: const Text("Pay with Stripe"),
            ),
          ],
        ),
      ),
    );
  }
}
