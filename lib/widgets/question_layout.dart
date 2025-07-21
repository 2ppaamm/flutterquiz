import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/app_colors.dart';
import '../theme/app_button_styles.dart';
import '../theme/app_font_styles.dart';

class QuestionLayout extends StatelessWidget {
  final BuildContext context;
  final int currentIndex;
  final bool submitted;
  final bool isCorrect;
  final int attempts;
  final List<dynamic> questions;
  final String? selectedOption;
  final Map<String, TextEditingController> fibControllers;
  final Map<int, String> answerKeyMap;
  final VoidCallback onSubmitAnswer;
  final VoidCallback onReset;
  final VoidCallback onSkip;
  final Function(String?) setSelectedOption;

  const QuestionLayout({
    super.key,
    required this.context,
    required this.currentIndex,
    required this.submitted,
    required this.isCorrect,
    required this.attempts,
    required this.questions,
    required this.selectedOption,
    required this.fibControllers,
    required this.answerKeyMap,
    required this.onSubmitAnswer,
    required this.onReset,
    required this.onSkip,
    required this.setSelectedOption,
  });

  @override
  Widget build(BuildContext context) {
    final q = questions[currentIndex];
    final typeId = q['type_id'];
    final isLast = currentIndex == questions.length - 1;

    return Scaffold(
      body: Container(
        color: AppColors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${q['skill']?['tracks']?[0]?['level']?['description'] ?? ''}',
              style: AppFontStyles.headingSubtitle,
            ),
            const SizedBox(height: 4),
            Text(
              '${q['skill']?['tracks']?[0]?['track'] ?? ''}',
              style: AppFontStyles.heading4,
            ),
            const SizedBox(height: 12),
            _buildProgressBar(),
            const SizedBox(height: 24),
            _renderHtmlWithLatex(q['question'] ?? ''),
            if (q['question_image'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.network(
                  "http://127.0.0.1:8000${q['question_image']}",
                  height: 180,
                ),
              ),
            if (typeId == 1)
              ...q.entries
                  .where((entry) => entry.key.startsWith('answer') && entry.value != null)
                  .map((entry) {
                final index = int.tryParse(entry.key.replaceAll('answer', '')) ?? 0;
                return _buildMCQOption(entry.value, index);
              }),
            const Spacer(),
            if (!submitted || isCorrect)
              ElevatedButton.icon(
                icon: isCorrect
                    ? Image.asset('assets/kudo.png', height: 20)
                    : const SizedBox.shrink(),
                label: Text(!submitted
                    ? 'Submit'
                    : isCorrect
                        ? 'Correct!'
                        : ''),
                style: submitted && isCorrect
                    ? AppButtonStyles.questionCorrect
                    : AppButtonStyles.questionPrimary,
                onPressed: onSubmitAnswer,
              ),
            if (submitted && !isCorrect && attempts < 2)
              Column(
                children: [
                  ElevatedButton(
                    style: AppButtonStyles.questionTryAgain,
                    onPressed: onReset,
                    child: const Text('Try Again!'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: AppButtonStyles.questionSkip,
                    onPressed: onSkip,
                    child: const Text('Skip Question'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.tileGrey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: (currentIndex + 1) / questions.length,
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.darkRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMCQOption(String? optionText, int index) {
    final isSelected = selectedOption == optionText;
    final isRight = submitted && isCorrect && isSelected;
    final isWrong = submitted && !isCorrect && isSelected;

    return GestureDetector(
      onTap: submitted ? null : () => setSelectedOption(optionText),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isRight
              ? Colors.green[50]
              : isWrong
                  ? Colors.red[50]
                  : AppColors.tileGrey,
          borderRadius: BorderRadius.circular(8.65),
          border: Border.all(
            color: isRight
                ? Colors.green
                : isWrong
                    ? Colors.red
                    : isSelected
                        ? AppColors.darkRed
                        : AppColors.lightGreyBackground,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _renderHtmlWithLatex(optionText ?? '')),
            if (isRight) const Icon(Icons.check_circle, color: Colors.green),
            if (isWrong) const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _renderHtmlWithLatex(String content) {
    final regex = RegExp(r'(\$\$.+?\$\$)', dotAll: true);
    final matches = regex.allMatches(content);
    List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      final start = match.start;
      final end = match.end;
      final matchedText = content.substring(start, end);

      if (start > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, start),
          style: AppFontStyles.questionText,
        ));
      }

      if (matchedText.startsWith(r'$$') && matchedText.endsWith(r'$$')) {
        final latex = matchedText.substring(2, matchedText.length - 2);
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            latex,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ));
      }

      currentIndex = end;
    }

    if (currentIndex < content.length) {
      final trailing = content.substring(currentIndex).trim();
      if (trailing.isNotEmpty) {
        spans.add(TextSpan(
          text: trailing,
          style: AppFontStyles.questionText,
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}