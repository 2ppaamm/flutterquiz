import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_button_styles.dart';
import 'question_feedback_widget.dart';

class QuestionFeedbackArea extends StatelessWidget {
  final bool isCorrect;
  final Map<String, dynamic> question;
  final String userAnswer;
  final VoidCallback onReportIssue;
  final VoidCallback onShowVideos;
  final bool unlimited;
  final Future<bool> Function() checkIsSubscriber;

  const QuestionFeedbackArea({
    super.key,
    required this.isCorrect,
    required this.question,
    required this.userAnswer,
    required this.onReportIssue,
    required this.onShowVideos,
    required this.unlimited,
    required this.checkIsSubscriber,
  });

  @override
  Widget build(BuildContext context) {
    final correctAnswerIndex = question['correct_answer'] as int? ?? 0;
    final explanation = question['explanation']?.toString();
    final questionType = question['type_id'] as int? ?? 1;

    // Get correct answer text for MCQ
    String? correctOptionText;
    if (questionType == 1) {
      correctOptionText = question['answer$correctAnswerIndex']?.toString();
    }

    // For Type 2: Get all acceptable answers
    List<String>? acceptableAnswers;
    if (questionType == 2) {
      acceptableAnswers = [
        if (question['answer0']?.toString().isNotEmpty ?? false)
          question['answer0'].toString(),
        if (question['answer1']?.toString().isNotEmpty ?? false)
          question['answer1'].toString(),
        if (question['answer2']?.toString().isNotEmpty ?? false)
          question['answer2'].toString(),
        if (question['answer3']?.toString().isNotEmpty ?? false)
          question['answer3'].toString(),
      ];
    }

    // Calculate kudos
    final difficultyId = question['difficulty_id'] as int? ?? 1;
    final kudosEarned = isCorrect ? (difficultyId + 1) : 1;

    // Get solutions, hints, videos
    final solutions = question['solutions'] as List? ?? [];
    final hints = question['hints'] as List? ?? [];
    final skill = question['skill'] as Map<String, dynamic>?;
    final videos = skill?['videos'] as List? ?? [];

    // Color scheme based on correct/incorrect
    final bgColor = isCorrect
        ? AppColors.success.withOpacity(0.1)
        : AppColors.error.withOpacity(0.1);
    final borderColor = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(12), // ✅ Reduce from 16 to 12
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing feedback widget
          QuestionFeedbackWidget(
            isCorrect: isCorrect,
            userAnswer: userAnswer,
            correctAnswer: correctAnswerIndex.toString(),
            explanation: explanation,
            onReportIssue: onReportIssue,
            questionType: questionType,
            correctOptionText: correctOptionText,
            acceptableAnswers: acceptableAnswers,
          ),

          const SizedBox(height: 12),

          // Bottom row: Kudos + Action buttons
          Row(
            children: [
              // Kudos
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: AppColors.success, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+$kudosEarned',
                      style: AppFontStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action buttons
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Solution button
                    if (solutions.isNotEmpty)
                      _buildCompactButton(
                        context,
                        icon: Icons.lightbulb_outline,
                        label: 'Solution',
                        onTap: () => _showSolutionDialog(context, solutions),
                      ),

                    // Hints button
                    if (hints.isNotEmpty)
                      _buildCompactButton(
                        context,
                        icon: Icons.tips_and_updates_outlined,
                        label: 'Hints',
                        onTap: () => _showHintsDialog(context, hints),
                      ),

                    // Videos button
                    if (videos.isNotEmpty)
                      FutureBuilder<bool>(
                        future: checkIsSubscriber(),
                        builder: (context, snapshot) {
                          final isSubscriber = snapshot.data ?? false;

                          return _buildCompactButton(
                            context,
                            icon: (!isSubscriber && unlimited)
                                ? Icons.lock_outline
                                : Icons.play_circle_outline,
                            label: 'Videos',
                            onTap: () {
                              if (!isSubscriber && unlimited) {
                                _showUpgradeDialog(
                                    context, skill?['skill'] ?? 'This Topic');
                              } else {
                                onShowVideos();
                              }
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.inputInactive),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.darkRed, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppFontStyles.caption.copyWith(
                color: AppColors.darkRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSolutionDialog(BuildContext context, List solutions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppColors.darkRed, size: 24),
            const SizedBox(width: 8),
            Text('Solution', style: AppFontStyles.headingMedium),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: solutions
                .map((solution) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        solution['solution'] ?? '',
                        style: AppFontStyles.bodyMedium,
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppFontStyles.buttonSecondary),
          ),
        ],
      ),
    );
  }

  void _showHintsDialog(BuildContext context, List hints) {
    final sortedHints = List.from(hints)
      ..sort((a, b) => (a['hint_level'] ?? 0).compareTo(b['hint_level'] ?? 0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.tips_and_updates_outlined,
                color: AppColors.darkGreyText, size: 24),
            const SizedBox(width: 8),
            Text('Hints', style: AppFontStyles.headingMedium),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: sortedHints
                .map((hint) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.darkGreyText,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${hint['hint_level'] ?? 1}',
                                style: AppFontStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hint['hint_text'] ?? '',
                              style: AppFontStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppFontStyles.buttonSecondary),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, String skillName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.darkRed, size: 24),
            const SizedBox(width: 8),
            Text('Premium Feature', style: AppFontStyles.headingMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unlock help videos for "$skillName" and all other topics',
              style: AppFontStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later', style: AppFontStyles.buttonSecondary),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Upgrade to Premium to unlock all videos!'),
                  backgroundColor: AppColors.darkRed,
                ),
              );
            },
            style: AppButtonStyles.primary,
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
