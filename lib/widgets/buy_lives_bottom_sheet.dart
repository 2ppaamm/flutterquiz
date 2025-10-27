import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/upgrade_service.dart';
import '../../services/payment_service.dart';

class BuyLivesBottomSheet extends StatelessWidget {
  const BuyLivesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

              // Title
              const Text(
                'Buy Lives',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Get back to practicing immediately',
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 32),

              // Lives packages
              _buildLivesPackage(
                context,
                lives: 5,
                price: 0.99,
                isPopular: false,
              ),

              const SizedBox(height: 12),

              _buildLivesPackage(
                context,
                lives: 10,
                price: 1.99,
                isPopular: true,
              ),

              const SizedBox(height: 12),

              _buildLivesPackage(
                context,
                lives: 20,
                price: 2.99,
                isPopular: false,
                savings: 'Save 25%',
              ),

              const SizedBox(height: 12),

              _buildLivesPackage(
                context,
                lives: null,
                price: 3.99,
                isPopular: false,
                label: 'Unlimited (24 hours)',
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.mediumGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              // Upsell to subscription
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: AppColors.darkRed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Save with Unlimited Lives',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Never run out again • From \$4.99/month',
                                style: TextStyle(
                                  color: AppColors.mediumGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          UpgradeService.showSubscriptionOptions(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.darkRed,
                            width: 2,
                          ),
                          foregroundColor: AppColors.darkRed,
                        ),
                        child: const Text('See Subscription Plans'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivesPackage(
    BuildContext context, {
    required int? lives,
    required double price,
    required bool isPopular,
    String? savings,
    String? label,
  }) {
    return InkWell(
      onTap: () => _handlePurchase(context, lives, price),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPopular ? AppColors.darkRed : Colors.grey[300]!,
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Lives icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  if (lives != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      'x$lives',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label ?? '$lives Lives',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (savings != null)
                    Text(
                      savings,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // Popular badge
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkRed,
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

            const SizedBox(width: 12),

            // Price
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
      BuildContext context, int? lives, double price) async {
    Navigator.pop(context);
    await PaymentService.purchaseLives(lives ?? 24, price);
  }
}
