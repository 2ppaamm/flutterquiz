import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';

/// Widget that displays feedback after a question is answered
/// Shows correct/incorrect status, user's answer, correct answer, and a flag button
class QuestionFeedbackWidget extends StatelessWidget {
  final bool isCorrect;
  final String? userAnswer;
  final String? correctAnswer;
  final String? explanation;
  final VoidCallback onReportIssue;
  final int questionType; // 1 = multiple choice, 2 = fill in blank
  final List<String>?
      acceptableAnswers; // For type 2 questions (answer0, answer1, answer2, answer3)
  final String?
      correctOptionText; // For type 1 questions (the actual text of correct option)

  const QuestionFeedbackWidget({
    super.key,
    required this.isCorrect,
    this.userAnswer,
    this.correctAnswer,
    this.explanation,
    required this.onReportIssue,
    required this.questionType,
    this.acceptableAnswers,
    this.correctOptionText,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            _buildAnswerComparison(),
            if (explanation != null && explanation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildExplanation(),
            ],
          ],
          if (isCorrect) ...[
            const SizedBox(height: 6),
            _buildSuccessMessage(),
          ],
        ],
      ),
    );
  }

  /// Get the formatted correct answer based on question type
  String _getFormattedCorrectAnswer() {
    if (questionType == 1) {
      // Type 1: Show the actual text content of the correct option
      return correctOptionText ?? correctAnswer ?? '';
    } else if (questionType == 2) {
      // Type 2: Show all acceptable answers separated by commas
      if (acceptableAnswers != null && acceptableAnswers!.isNotEmpty) {
        return acceptableAnswers!.where((a) => a.isNotEmpty).join(', ');
      }
    }
    return correctAnswer ?? '';
  }

  /// Header row with status icon, message, and flag button
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? AppColors.success : AppColors.error,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isCorrect ? 'Correct! Well done!' : 'Incorrect',
            style: AppFontStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: isCorrect ? AppColors.success : AppColors.error,
            ),
          ),
        ),
        // Flag button for reporting issues
        IconButton(
          icon: Icon(
            Icons.flag_outlined,
            color: AppColors.darkGrey,
            size: 24,
          ),
          onPressed: onReportIssue,
          tooltip: 'Report Issue',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }

  /// Shows user's answer vs correct answer comparison
  Widget _buildAnswerComparison() {
    final formattedCorrectAnswer = _getFormattedCorrectAnswer();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User's answer
          if (userAnswer != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.close, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your answer:',
                        style: AppFontStyles.caption.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userAnswer!,
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Correct answer
          if (formattedCorrectAnswer.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionType == 2
                            ? 'Acceptable answers:'
                            : 'Correct answer:',
                        style: AppFontStyles.caption.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedCorrectAnswer,
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Shows explanation for the correct answer
  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.levelBeginner.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.levelBeginner.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppColors.levelBeginner,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation',
                  style: AppFontStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation!,
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

  /// Success message for correct answers
  Widget _buildSuccessMessage() {
    return Text(
      'Keep up the great work!',
      style: AppFontStyles.bodyMedium.copyWith(
        color: AppColors.success.withOpacity(0.8),
      ),
    );
  }
}
