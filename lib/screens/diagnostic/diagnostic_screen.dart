import 'package:flutter/material.dart';
import '../../models/diagnostic_question.dart';
import '../../services/diagnostic_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_font_styles.dart';
import '../../theme/app_button_styles.dart';
import '../../utils/math_text_utils.dart';
import '../../widgets/common_question_widgets.dart';
import '../../widgets/out_of_lives_modal.dart';
import '../../widgets/lives_header.dart';
import 'diagnostic_result_screen.dart';
import '../../widgets/html_latex_renderer.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  // Session & Questions
  int? _sessionId;
  List<DiagnosticQuestion> _questions = [];
  List<DiagnosticAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionId;

  // UI State
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  bool _hasShownModal = false;

  // Lives Data
  int _lives = 0;
  int _maxLives = 5;
  bool _unlimitedLives = false;
  bool _canAnswer = true;
  int? _nextLifeInSeconds;
  String? _nextLifeAt;

  @override
  void initState() {
    super.initState();
    _startDiagnostic();
  }

  // ========== API METHODS ==========

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

      // Handle out of lives response
      if (result['ok'] == false) {
        _updateLivesData(result);
        setState(() {
          _loading = false;
        });
        return;
      }

      // Success - load questions
      _sessionId = result['session_id'] as int;
      _updateLivesData(result);
      _loadQuestions(result['questions'] as List);
    } catch (e) {
      print('❌ Error starting diagnostic: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _submitBatch() async {
    if (_sessionId == null || !mounted) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      // Remove is_correct from answers - backend will determine this
      final answersToSubmit = _answers
          .map((a) => {
                'question_id': a.questionId,
                'selected_option_id': a.selectedOptionId,
                'answered_at': a.answeredAt.toIso8601String(),
              })
          .toList();

      final result = await DiagnosticService.submitDiagnostic(
        _sessionId!,
        answersToSubmit,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _error = 'Failed to submit diagnostic. Please try again.';
          _submitting = false;
        });
        return;
      }

      // Update lives data after submission
      _updateLivesData(result);

      // ✅ Check if diagnostic is completed
      if (result['diagnostic_completed'] == true) {
        if (mounted) {
          setState(() => _submitting = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DiagnosticResultScreen(result: result),
            ),
          );
        }
        return;
      }

      // ✅ Check if there are more questions (backend returns 'questions' key)
      if (result['questions'] != null &&
          (result['questions'] as List).isNotEmpty) {
        _loadQuestions(result['questions'] as List);
      } else {
        // No more questions - shouldn't happen but handle gracefully
        if (mounted) {
          setState(() => _submitting = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DiagnosticResultScreen(result: result),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error submitting batch: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to submit. Please try again.';
        _submitting = false;
      });
    }
  }

  // ========== DATA METHODS ==========

  void _updateLivesData(Map<String, dynamic> result) {
    // Only parse lives data if it exists in response
    // Premium/SIMBA users won't have lives data in response
    if (result.containsKey('lives')) {
      print('📊 Lives Update:');
      print('  Lives: ${result['lives']}');
      print('  Max Lives: ${result['max_lives']}');
      print('  Can Answer: ${result['can_answer']}');
      print('  Unlimited: ${result['unlimited']}');
      print('  Next Life In: ${result['next_life_in_seconds']}s');

      setState(() {
        _lives = result['lives'] ?? 0;
        _maxLives = result['max_lives'] ?? 5;
        _unlimitedLives = result['unlimited'] ?? false;
        _canAnswer = result['can_answer'] ?? true;
        _nextLifeInSeconds = result['next_life_in_seconds'];
        _nextLifeAt = result['next_life_at'];
      });
    } else {
      // No lives data in response = unlimited (Premium/SIMBA)
      print('📊 No lives data - Premium/SIMBA user');
      setState(() {
        _unlimitedLives = true;
        _canAnswer = true;
        _lives = 0;
        _maxLives = 0;
        _nextLifeInSeconds = null;
        _nextLifeAt = null;
      });
    }
  }

  void _loadQuestions(List<dynamic> questionsData) {
    if (!mounted) return;

    try {
      final parsedQuestions =
          questionsData.map((q) => DiagnosticQuestion.fromJson(q)).toList();

      setState(() {
        _questions = parsedQuestions;
        _currentQuestionIndex = 0;
        _selectedOptionId = null;
        _answers.clear();
        _loading = false;
        _submitting = false;
      });
    } catch (e) {
      print('❌ Error loading questions: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load questions: $e';
          _loading = false;
        });
      }
    }
  }

  void _selectOption(int optionId) {
    setState(() {
      _selectedOptionId = optionId;
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedOptionId == null) return;

    final currentQuestion = _questions[_currentQuestionIndex];

    // Store answer (backend will determine correctness)
    final answer = DiagnosticAnswer(
      questionId: currentQuestion.id,
      selectedOptionId: _selectedOptionId!,
      isCorrect: false, // Placeholder - backend validates
      answeredAt: DateTime.now(),
    );
    _answers.add(answer);

    // Move to next question or submit batch
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionId = null;
      });
    } else {
      await _submitBatch();
    }
  }

  // ========== BUILD METHODS ==========

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return CommonQuestionWidgets.buildLoadingState();
    }

    // ✅ Only show out of lives modal if:
    // - No lives AND
    // - Not unlimited AND
    // - Not submitting AND
    // - Questions are empty (so we're not mid-diagnostic)
    if (!_canAnswer &&
        !_unlimitedLives &&
        !_hasShownModal &&
        !_submitting &&
        _questions.isEmpty) {
      Future.microtask(() {
        if (mounted) {
          _hasShownModal = true;
          OutOfLivesModal.show(
            context,
            nextLifeInSeconds: _nextLifeInSeconds ?? 0,
            onGoBack: () {
              Navigator.pop(context); // Close modal
              Navigator.pop(context); // Go back from diagnostic screen
            },
            customMessage: 'You need lives to continue the diagnostic test.',
          );
        }
      });

      // Return empty scaffold while modal shows
      return Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        body: Container(),
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
            // ✅ Lives header - will hide itself if unlimited
            LivesHeader(
              lives: _lives,
              maxLives: _maxLives,
              unlimited: _unlimitedLives,
              nextLifeInSeconds: _nextLifeInSeconds,
              onTimerUpdate: (remainingSeconds) {
                if (mounted) {
                  setState(() {
                    _nextLifeInSeconds = remainingSeconds;
                  });
                }
              },
            ),

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
              constraints: BoxConstraints(maxHeight: 400),
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
          }).toList(),
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
                      decoration: BoxDecoration(
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
              constraints: BoxConstraints(maxHeight: 60, maxWidth: 100),
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
            shape: MaterialStateProperty.all(
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
