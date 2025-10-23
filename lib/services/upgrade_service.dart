import 'package:flutter/material.dart';
import '../widgets/subscription/subscription_options_sheet.dart';

class UpgradeService {
  /// Shows subscription options with multiple tiers
  static void showSubscriptionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubscriptionOptionsSheet(),
    );
  }
  
  /// Alias - same as showSubscriptionOptions
  static void showUpgradePrompt(BuildContext context) {
    showSubscriptionOptions(context);
  }
}