import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: Text('Upgrade to Premium', style: AppFontStyles.heading2),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Center(
                child: Icon(
                  Icons.stars,
                  size: 80,
                  color: AppColors.darkRed,
                ),
              ),
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  'Unlock Premium Features',
                  style: AppFontStyles.heading1,
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Premium Benefits
              _buildBenefit(
                icon: Icons.auto_awesome,
                title: 'AI-Powered Kiasu Path',
                description: 'Personalized learning path that adapts to your progress',
                badge: 'EXCLUSIVE',
              ),
              
              _buildBenefit(
                icon: Icons.favorite,
                title: 'Unlimited Practice',
                description: 'No lives restriction - practice as much as you want',
                badge: 'UNLIMITED',
              ),
              
              _buildBenefit(
                icon: Icons.insights,
                title: 'Advanced Analytics',
                description: 'Detailed insights and progress tracking across all subjects',
              ),
              
              _buildBenefit(
                icon: Icons.block,
                title: 'Ad-Free Experience',
                description: 'Focus on learning without any interruptions',
              ),
              
              _buildBenefit(
                icon: Icons.emoji_events,
                title: 'Priority Support',
                description: 'Get help faster with dedicated premium support',
              ),
              
              const SizedBox(height: 24),
              
              // Diagnostic Note (Important clarification)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.levelGrowing.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.levelGrowing.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.levelGrowing,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Diagnostic Tests',
                            style: AppFontStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.levelGrowing,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All users (free and premium) take diagnostic tests every 30 days for best learning results.',
                            style: AppFontStyles.bodyMedium.copyWith(
                              color: AppColors.darkGreyText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Pricing Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkRed, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Premium Monthly',
                      style: AppFontStyles.heading2.copyWith(
                        color: AppColors.darkRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$',
                          style: AppFontStyles.heading2.copyWith(
                            color: AppColors.darkRed,
                          ),
                        ),
                        Text(
                          '9.99',
                          style: AppFontStyles.heading1.copyWith(
                            fontSize: 48,
                            color: AppColors.darkRed,
                          ),
                        ),
                        Text(
                          '/mo',
                          style: AppFontStyles.bodyLarge.copyWith(
                            color: AppColors.darkRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement subscription flow
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subscription coming soon!'),
                            ),
                          );
                        },
                        style: AppButtonStyles.primary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Start Premium',
                            style: AppFontStyles.buttonPrimary.copyWith(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Cancel anytime text
              Center(
                child: Text(
                  'Cancel anytime. No commitment.',
                  style: AppFontStyles.bodyMedium.copyWith(
                    color: AppColors.darkGreyText,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppFontStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: AppFontStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppFontStyles.bodyMedium.copyWith(
                    color: AppColors.darkGreyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}