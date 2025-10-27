import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import 'package:intl/intl.dart';

/// Shows dialog when user tries to take diagnostic but needs to wait
/// The 30-day restriction applies to ALL users (free and premium) for pedagogical reasons
class DiagnosticUnavailableDialog extends StatelessWidget {
  final DateTime nextAvailableDate;
  final VoidCallback onViewLastResults;
  final VoidCallback onExploreTopics;
  final VoidCallback onUpgradeToPremium;

  const DiagnosticUnavailableDialog({
    super.key,
    required this.nextAvailableDate,
    required this.onViewLastResults,
    required this.onExploreTopics,
    required this.onUpgradeToPremium,
  });

  String _getDaysRemaining() {
    final now = DateTime.now();
    final difference = nextAvailableDate.difference(now);
    final daysRemaining = difference.inDays;
    
    if (daysRemaining == 0) {
      return 'Available tomorrow';
    } else if (daysRemaining == 1) {
      return '1 day remaining';
    } else {
      return '$daysRemaining days remaining';
    }
  }

  String _getFormattedDate() {
    return DateFormat('MMM d, yyyy').format(nextAvailableDate);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        // ✅ Make it scrollable to prevent overflow
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.levelGrowing.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 48,
                    color: AppColors.levelGrowing,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Diagnostic Test on Cooldown',
                  style: AppFontStyles.heading2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Explanation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Diagnostic tests work best when taken every 30 days. This allows enough time for meaningful learning progress.',
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.darkGreyText,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.darkRed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available: ${_getFormattedDate()}',
                            style: AppFontStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDaysRemaining(),
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Alternative Actions
                Text(
                  'What you can do now:',
                  style: AppFontStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Action Button 1: View Last Results
                _buildActionButton(
                  icon: Icons.assessment_rounded,
                  label: 'View Last Diagnostic Results',
                  color: AppColors.levelAdvanced,
                  onTap: () {
                    Navigator.of(context).pop();
                    onViewLastResults();
                  },
                ),
                
                const SizedBox(height: 10),
                
                // Action Button 2: Explore Topics (Browse Topics color from home screen)
                _buildActionButton(
                  icon: Icons.explore_rounded,
                  label: 'Explore Topics',
                  color: AppColors.darkGreyText, // ✅ Matches "Browse Topics" button
                  onTap: () {
                    Navigator.of(context).pop();
                    onExploreTopics();
                  },
                ),
                
                const SizedBox(height: 10),
                
                // Action Button 3: Upgrade to Premium (Kiasu button color)
                _buildActionButton(
                  icon: Icons.workspace_premium,
                  label: 'Upgrade to Premium',
                  color: AppColors.darkRed, // ✅ Matches Kiasu button when locked
                  onTap: () {
                    Navigator.of(context).pop();
                    onUpgradeToPremium();
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Close Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'Close',
                    style: AppFontStyles.bodyMedium.copyWith(
                      color: AppColors.darkGreyText,
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

/// Helper function to show the dialog
void showDiagnosticUnavailableDialog({
  required BuildContext context,
  required DateTime nextAvailableDate,
  required VoidCallback onViewLastResults,
  required VoidCallback onExploreTopics,
  required VoidCallback onUpgradeToPremium,
}) {
  showDialog(
    context: context,
    builder: (context) => DiagnosticUnavailableDialog(
      nextAvailableDate: nextAvailableDate,
      onViewLastResults: onViewLastResults,
      onExploreTopics: onExploreTopics,
      onUpgradeToPremium: onUpgradeToPremium,
    ),
  );
}