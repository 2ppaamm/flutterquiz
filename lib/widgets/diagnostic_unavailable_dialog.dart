import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

class DiagnosticUnavailableDialog extends StatelessWidget {
  final DateTime nextAvailableDate;
  final VoidCallback onViewLastResults;
  final VoidCallback onPracticeNow;
  final VoidCallback onExploreTopics;

  const DiagnosticUnavailableDialog({
    Key? key,
    required this.nextAvailableDate,
    required this.onViewLastResults,
    required this.onPracticeNow,
    required this.onExploreTopics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _calculateDaysRemaining();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 40,
                color: AppColors.darkRed,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Diagnostic Test Unavailable',
              style: AppFontStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'You can only take the diagnostic test once every 30 days to ensure accurate progress tracking.',
              style: AppFontStyles.bodyMedium.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Next Available Date Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkRed.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.darkRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next Available',
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.darkRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(nextAvailableDate),
                    style: AppFontStyles.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$daysRemaining days remaining',
                    style: AppFontStyles.bodyMedium.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Container(
              height: 1,
              color: Colors.grey.withOpacity(0.2),
            ),
            const SizedBox(height: 20),

            // What You Can Do Section
            Text(
              'What you can do now:',
              style: AppFontStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButton(
              icon: Icons.assessment,
              label: 'View Last Results',
              color: AppColors.darkRed,
              onTap: () {
                Navigator.of(context).pop();
                onViewLastResults();
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.play_circle_outline,
              label: 'Practice Now',
              color: AppColors.pink,
              onTap: () {
                Navigator.of(context).pop();
                onPracticeNow();
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.explore,
              label: 'Explore Topics',
              color: AppColors.yellow,
              onTap: () {
                Navigator.of(context).pop();
                onExploreTopics();
              },
            ),
            const SizedBox(height: 20),

            // Close Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Close',
                style: AppFontStyles.bodyMedium.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  int _calculateDaysRemaining() {
    final now = DateTime.now();
    final difference = nextAvailableDate.difference(now);
    return difference.inDays + 1;
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppFontStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

void showDiagnosticUnavailableDialog({
  required BuildContext context,
  required DateTime nextAvailableDate,
  required VoidCallback onViewLastResults,
  required VoidCallback onPracticeNow,
  required VoidCallback onExploreTopics,
}) {
  showDialog(
    context: context,
    builder: (context) => DiagnosticUnavailableDialog(
      nextAvailableDate: nextAvailableDate,
      onViewLastResults: onViewLastResults,
      onPracticeNow: onPracticeNow,
      onExploreTopics: onExploreTopics,
    ),
  );
}