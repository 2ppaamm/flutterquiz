import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  // CHANGE THIS to your actual website URL when ready
  static const String websiteUrl = 'https://math.allgifted.com';
  
  static Future<void> openWebSubscription() async {
    final url = Uri.parse('$websiteUrl/subscribe');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  
  static Future<void> purchaseLives(int lives, double price) async {
    final url = Uri.parse('$websiteUrl/buy-lives?lives=$lives');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}