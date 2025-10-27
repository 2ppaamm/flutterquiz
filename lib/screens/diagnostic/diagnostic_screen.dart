import 'package:flutter/material.dart';
import '../../models/diagnostic_question.dart';
import '../../services/diagnostic_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_font_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../utils/math_text_utils.dart';
import '../../widgets/common_question_widgets.dart';
import 'diagnostic_result_screen.dart';
import '../../widgets/html_latex_renderer.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  // Session & Questions
  int? _sessionId;
  List<DiagnosticQuestion> _questions = [];
  final List<DiagnosticAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionId;

  // UI State
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDiagnostic();
  }

  Future<void> _startDiagnostic() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await DiagnosticService.startDiagnostic();

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _error = 'Failed to start diagnostic. Please try again.';
          _loading = false;
        });
        return;
      }

      final responseType = DiagnosticService.getResponseType(result);

      switch (responseType) {
        case DiagnosticResponseType.cooldown:
          // ✅ Handle 30-day cooldown
          _showCooldownDialog(result);
          setState(() => _loading = false);
          break;

        case DiagnosticResponseType.questions:
          final questionsData = result['questions'] as List?;
          if (questionsData == null || questionsData.isEmpty) {
            setState(() {
              _error = 'No questions available';
              _loading = false;
            });
            return;
          }

          setState(() {
            _sessionId = result['session_id'] as int?;
            _questions = questionsData
                .map((q) => DiagnosticQuestion.fromJson(q))
                .toList();
            _currentQuestionIndex = 0;
            _selectedOptionId = null;
            _answers.clear();
            _loading = false;
          });
          break;

        case DiagnosticResponseType.results:
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DiagnosticResultScreen(result: result),
            ),
          );
          break;

        case DiagnosticResponseType.error:
        default:
          setState(() {
            _error = result['message'] ?? 'An error occurred';
            _loading = false;
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error starting diagnostic: $e';
        _loading = false;
      });
    }
  }

  void _showCooldownDialog(Map<String, dynamic> data) {
    final daysRemaining = data['days_remaining'] ?? 0;
    final nextAvailableDate = data['next_available_date'] as String?;
    
    String formattedDate = 'in $daysRemaining days';
    if (nextAvailableDate != null) {
      try {  // ✅ FIXED: Was "try o{" before
        final date = DateTime.parse(nextAvailableDate);
        formattedDate = '${date.month}/${date.day}/${date.year}';
      } catch (e) {
        // Use days remaining as fallback
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.access_time, color: AppColors.darkRed, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Diagnostic Available Soon',
                style: AppFontStyles.heading2.copyWith(
                  color: AppColors.darkRed,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You can retake the diagnostic once per month to track your learning progress.',
              style: AppFontStyles.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGreyBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Next diagnostic:',
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: AppFontStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Days remaining:',
                        style: AppFontStyles.bodyMedium.copyWith(
                          color: AppColors.darkGreyText,
                        ),
                      ),
                      Text(
                        '$daysRemaining days',
                        style: AppFontStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '💡 Why wait?',
              style: AppFontStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your learning level has been determined! Keep practicing to improve, and we\'ll reassess your progress next month.',
              style: AppFontStyles.bodyMedium.copyWith(
                color: AppColors.darkGreyText,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              style: AppButtonStyles.primary,
              child: Text('Back to Learning', style: AppFontStyles.buttonPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _selectOption(int optionId) {
    setState(() {
      _selectedOptionId = optionId;
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedOptionId == null || _sessionId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final currentQuestion = _questions[_currentQuestionIndex];
      
      // Check if answer is correct
      final isCorrect = currentQuestion.correctOptionId == _selectedOptionId;
      
      // Store answer
      _answers.add(DiagnosticAnswer(
        questionId: currentQuestion.id,
        selectedOptionId: _selectedOptionId!,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
      ));

      // Check if this was the last question in the batch
      if (_currentQuestionIndex < _questions.length - 1) {
        // Move to next question
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionId = null;
          _submitting = false;
        });
      } else {
        // Submit all answers
        await _submitBatch();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error submitting answer: $e';
        _submitting = false;
      });
    }
  }

  Future<void> _submitBatch() async {
    try {
      final result = await DiagnosticService.submitDiagnostic(
        _sessionId!,
        _answers.map((a) => a.toJson()).toList(),
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _error = 'Failed to submit answers';
          _submitting = false;
        });
        return;
      }

      final responseType = DiagnosticService.getResponseType(result);

      switch (responseType) {
        case DiagnosticResponseType.questions:
          // More questions - load next batch
          final questionsData = result['questions'] as List?;
          final nextQuestions = result['next_questions'] as List?;
          final dataToLoad = questionsData ?? nextQuestions;

          if (dataToLoad == null || dataToLoad.isEmpty) {
            setState(() {
              _error = 'No more questions available';
              _submitting = false;
            });
            return;
          }

          setState(() {
            _questions = dataToLoad
                .map((q) => DiagnosticQuestion.fromJson(q))
                .toList();
            _currentQuestionIndex = 0;
            _selectedOptionId = null;
            _answers.clear();
            _submitting = false;
          });
          break;

        case DiagnosticResponseType.results:
          // Diagnostic complete - show results
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DiagnosticResultScreen(result: result),
            ),
          );
          break;

        case DiagnosticResponseType.error:
        default:
          setState(() {
            _error = result['message'] ?? 'An error occurred';
            _submitting = false;
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error submitting batch: $e';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.darkRed),
              const SizedBox(height: 16),
              Text(
                'Preparing your diagnostic...',
                style: AppFontStyles.bodyLarge.copyWith(
                  color: AppColors.darkGreyText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_error != null) {
      return CommonQuestionWidgets.buildErrorState(
        errorMessage: _error!,
        onRetry: _startDiagnostic,
      );
    }

    // Empty state
    if (_questions.isEmpty) {
      return CommonQuestionWidgets.buildEmptyState();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            CommonQuestionWidgets.buildProgressHeader(
              progress: progress,
              currentIndex: _currentQuestionIndex,
              totalQuestions: _questions.length,
            ),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildQuestionCard(currentQuestion),
              ),
            ),

            // Submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(DiagnosticQuestion question) {
    return CommonQuestionWidgets.buildQuestionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text with LaTeX support
          MathTextUtils.renderMathText(question.question),
          const SizedBox(height: 24),

          // Question image
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
          ],
          // Options
          ...question.options.map((option) {
            final isSelected = _selectedOptionId == option.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionCard(
                option: option,
                isSelected: isSelected,
                onTap: _submitting ? null : () => _selectOption(option.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required DiagnosticOption option,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkRed.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.darkRed : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
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
                color: isSelected ? AppColors.darkRed : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Option text with LaTeX support
            Expanded(
              child: HtmlLatexRenderer.renderInlineHtml(option.text),
            ),
            
            // Option image if exists
            if (option.imageUrl != null && option.imageUrl!.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 60, maxWidth: 100),
                child: Image.network(
                  option.imageUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              _selectedOptionId == null || _submitting ? null : _submitAnswer,
          style: AppButtonStyles.primary.copyWith(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: _submitting
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? 'Next Question'
                          : 'Submit 🎉',
                      style: AppFontStyles.buttonPrimary.copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: AppColors.white),
                  ],
                ),
        ),
      ),
    );
  }
}