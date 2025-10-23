import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/upgrade_service.dart';
import 'subscription/buy_lives_bottom_sheet.dart';

class OutOfLivesModal {
  static void show(
    BuildContext context, {
    required int nextLifeInSeconds,
    required VoidCallback onGoBack,
    String? customMessage,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => _OutOfLivesDialog(
        nextLifeInSeconds: nextLifeInSeconds,
        onGoBack: onGoBack,
        customMessage: customMessage,
      ),
    );
  }
}

class _OutOfLivesDialog extends StatelessWidget {
  final int nextLifeInSeconds;
  final VoidCallback onGoBack;
  final String? customMessage;

  const _OutOfLivesDialog({
    required this.nextLifeInSeconds,
    required this.onGoBack,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heart icon
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppColors.darkRed.withOpacity(0.5),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Out of Lives!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkRed,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Message
                Text(
                  customMessage ?? 'You need lives to continue practicing.',
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Timer card (compact)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreyBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 18,
                        color: AppColors.darkRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next free life in ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      Text(
                        _formatTime(nextLifeInSeconds),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider with text
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Choose how to continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Option 1: Buy Lives (Quick Solution)
                _buildOptionCard(
                  context: context,
                  icon: Icons.favorite,
                  iconColor: Colors.blue[700]!,
                  iconBackground: Colors.blue[50]!,
                  title: 'Buy Lives',
                  description: 'Get back in action fast\nStarting at \$0.99',
                  onTap: () {
                    Navigator.pop(context);
                    _showBuyLivesModal(context);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Option 2: Get Unlimited (Best Value)
                _buildOptionCard(
                  context: context,
                  icon: Icons.flash_on,
                  iconColor: Colors.white,
                  iconBackground: AppColors.darkRed,
                  title: 'Unlimited Lives',
                  description: 'Practice anytime, no limits\nBest for serious learners',
                  badge: 'BEST',
                  isHighlighted: true,
                  onTap: () {
                    Navigator.pop(context);
                    UpgradeService.showSubscriptionOptions(context);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Go Back button (subtle)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onGoBack();
                  },
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String description,
    required VoidCallback onTap,
    String? badge,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted 
              ? AppColors.darkRed.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted 
                ? AppColors.darkRed 
                : Colors.grey[300]!,
            width: isHighlighted ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 14),
                
                // Text - give it flexible space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isHighlighted 
                              ? AppColors.darkRed 
                              : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.mediumGrey,
                  size: 16,
                ),
              ],
            ),
            
            // Badge positioned absolutely in top right corner
            if (badge != null)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  void _showBuyLivesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BuyLivesBottomSheet(),
    );
  }
}