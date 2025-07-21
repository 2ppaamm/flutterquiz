import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ag_math/config.dart';

class StripeService {
  static Future<void> startCheckoutSession() async {
    // Replace with your actual backend call to create payment intent
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/create-payment-intent'), // Your Laravel route
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': 9900, 'currency': 'usd'}), // $99.00
    );

    final json = jsonDecode(response.body);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: json['clientSecret'],
        merchantDisplayName: 'All Gifted',
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
