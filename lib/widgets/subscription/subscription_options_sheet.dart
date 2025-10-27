import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_button_styles.dart';
import '../../services/payment_service.dart';

class SubscriptionOptionsSheet extends StatefulWidget {
  const SubscriptionOptionsSheet({super.key});

  @override
  State<SubscriptionOptionsSheet> createState() =>
      _SubscriptionOptionsSheetState();
}

class _SubscriptionOptionsSheetState extends State<SubscriptionOptionsSheet> {
  String _selectedPlan = 'family'; // Default to recommended plan

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flash_on,
                      color: AppColors.darkRed,
                      size: 48,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'All plans include unlimited lives and no ads',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Subscription cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSubscriptionCard(
                      id: 'student',
                      title: 'Student',
                      subtitle: 'Perfect for individual learners',
                      monthlyPrice: 15,
                      yearlyPrice: 120,
                      features: [
                        'Unlimited lives',
                        'No ads',
                        'Priority support',
                        'Offline mode',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSubscriptionCard(
                      id: 'family',
                      title: 'Family',
                      subtitle: 'Best for families with kids',
                      monthlyPrice: 25,
                      yearlyPrice: 240,
                      isRecommended: true,
                      features: [
                        'Everything in Student',
                        'Up to 4 family members',
                        'Parent dashboard & analytics',
                        'Weekly progress reports',
                        'Parents can practice too!',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSubscriptionCard(
                      id: 'teacher',
                      title: 'Teacher Pro',
                      subtitle: 'For tutors and small groups',
                      monthlyPrice: null,
                      yearlyPrice: 1200,
                      features: [
                        'Everything in Family',
                        'Up to 8 students',
                        'Class analytics',
                        'Custom assignments',
                        'Progress tracking',
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // CTA Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handleSubscribe(),
                      style: AppButtonStyles.primary.copyWith(
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.darkRed),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Start Subscription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cancel anytime • No commitment',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String id,
    required String title,
    required String subtitle,
    required int? monthlyPrice,
    required int yearlyPrice,
    required List<String> features,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPlan == id;

    return InkWell(
      onTap: () => setState(() => _selectedPlan = id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.darkRed.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.darkRed : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.darkRed : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (monthlyPrice != null) ...[
                      Text(
                        '\$$monthlyPrice',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/month',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '\$$yearlyPrice',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/year',
                        style: TextStyle(
                          color: AppColors.mediumGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features
            ...features
                .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe() async {
    Navigator.pop(context);
    await PaymentService.openWebSubscription();
  }
}
