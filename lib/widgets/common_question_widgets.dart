import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../utils/math_text_utils.dart';

/// Common widgets used across question screens
class CommonQuestionWidgets {
  /// Build a progress header with emoji, progress bar, and counter
  static Widget buildProgressHeader({
    required double progress,
    required int currentIndex,
    required int totalQuestions,
    String emoji = '🎯',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.lightGrey,
                valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${currentIndex + 1}/$totalQuestions',
            style: AppFontStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkRed,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a network image with loading and error states
  static Widget buildNetworkImage({
    required String imageUrl,
    double? maxHeight = 300,
    BoxFit fit = BoxFit.contain,
    BorderRadius? borderRadius,
  }) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    return Container(
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight) : null,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.red),
                  SizedBox(height: 8),
                  Text(
                    'Image failed to load',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build a loading state screen
  static Widget buildLoadingState({String message = 'Loading questions...'}) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppFontStyles.bodyLarge.copyWith(
                color: AppColors.darkGreyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build an error state screen with retry button
  static Widget buildErrorState({
    required String errorMessage,
    required VoidCallback onRetry,
    String buttonText = 'Try Again',
  }) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: AppFontStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonText, style: AppFontStyles.buttonPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build an empty state screen
  static Widget buildEmptyState({String message = 'No questions available'}) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Text(
          message,
          style: AppFontStyles.bodyLarge,
        ),
      ),
    );
  }

  /// Build a question card container
  static Widget buildQuestionCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Build a radio/check button for options
  static Widget buildRadioButton({
    required bool isSelected,
    double size = 24,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.darkRed : AppColors.mediumGrey,
          width: 2,
        ),
        color: isSelected ? AppColors.darkRed : AppColors.white,
      ),
      child: isSelected
          ? Icon(Icons.check, size: size * 0.67, color: AppColors.white)
          : null,
    );
  }

  // ==================== ANSWER OPTION WIDGETS ====================

  /// Build a text-only answer option for multiple choice questions
  static Widget buildAnswerOption({
    required String answer,
    required bool isSelected,
    required bool hasAnswered,
    required bool isCorrect,
    required bool isCorrectAnswer,
    required VoidCallback onTap,
  }) {
    Color backgroundColor = AppColors.white;
    Color borderColor = AppColors.inputInactive;

    if (hasAnswered && isSelected) {
      backgroundColor = isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (hasAnswered && isCorrectAnswer && !isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
    } else if (isSelected) {
      backgroundColor = AppColors.darkRed.withOpacity(0.1);
      borderColor = AppColors.darkRed;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasAnswered ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Expanded(child: MathTextUtils.renderMathText(answer)),
                if (hasAnswered && isSelected && isCorrect)
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
                if (hasAnswered && isSelected && !isCorrect)
                  Icon(Icons.cancel, color: AppColors.error, size: 24),
                if (hasAnswered && isCorrectAnswer && !isCorrect && !isSelected)
                  Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build an image-based answer option for multiple choice questions
  static Widget buildImageAnswerOption({
    required String answer,
    required String? answerImage,
    required String apiBaseUrl,
    required bool isSelected,
    required bool hasAnswered,
    required bool isCorrect,
    required bool isCorrectAnswer,
    required VoidCallback onTap,
  }) {
    Color backgroundColor = AppColors.white;
    Color borderColor = AppColors.inputInactive;

    if (hasAnswered && isSelected) {
      backgroundColor = isCorrect
          ? AppColors.success.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1);
      borderColor = isCorrect ? AppColors.success : AppColors.error;
    } else if (hasAnswered && isCorrectAnswer && !isCorrect) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      borderColor = AppColors.success;
    } else if (isSelected) {
      backgroundColor = AppColors.darkRed.withOpacity(0.1);
      borderColor = AppColors.darkRed;
    }

    // Build full image URL with /media path
    String fullImageUrl = '';
    if (answerImage != null && answerImage.isNotEmpty) {
      if (answerImage.startsWith('http://') || answerImage.startsWith('https://')) {
        fullImageUrl = answerImage;
      } else if (answerImage.startsWith('/media')) {
        fullImageUrl = "$apiBaseUrl$answerImage";
      } else {
        fullImageUrl = "$apiBaseUrl/media$answerImage";
      }
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasAnswered ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section
              if (fullImageUrl.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        fullImageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, 
                                    size: 32, 
                                    color: AppColors.mediumGrey),
                                SizedBox(height: 4),
                                Text(
                                  'Image failed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mediumGrey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              // Text section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          answer,
                          style: AppFontStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (hasAnswered && isSelected && isCorrect)
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                    if (hasAnswered && isSelected && !isCorrect)
                      Icon(Icons.cancel, color: AppColors.error, size: 20),
                    if (hasAnswered &&
                        isCorrectAnswer &&
                        !isCorrect &&
                        !isSelected)
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FILL-IN-THE-BLANK WIDGETS ====================

  /// Build a number pad for fill-in-the-blank questions
  static Widget buildNumberPad({
    required Function(String) onNumberPressed,
    required VoidCallback onBackspace,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1', onNumberPressed),
              _buildNumberButton('2', onNumberPressed),
              _buildNumberButton('3', onNumberPressed),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4', onNumberPressed),
              _buildNumberButton('5', onNumberPressed),
              _buildNumberButton('6', onNumberPressed),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7', onNumberPressed),
              _buildNumberButton('8', onNumberPressed),
              _buildNumberButton('9', onNumberPressed),
            ],
          ),
          const SizedBox(height: 8),
          // Row 4: 0, Backspace, Clear
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('0', onNumberPressed),
              _buildActionButton('⌫', onBackspace),
              _buildActionButton('Clear', onClear, isWide: true),
            ],
          ),
        ],
      ),
    );
  }

  /// Build individual number button
  static Widget _buildNumberButton(String number, Function(String) onPressed) {
    return SizedBox(
      width: 100,
      height: 60,
      child: ElevatedButton(
        onPressed: () => onPressed(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkText,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.lightGrey, width: 1),
          ),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build action button (backspace/clear)
  static Widget _buildActionButton(
    String label,
    VoidCallback onPressed, {
    bool isWide = false,
  }) {
    return SizedBox(
      width: isWide ? 120 : 100,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightGrey,
          foregroundColor: AppColors.darkText,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: label == '⌫' ? 24 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build a clickable blank input field for fill-in-the-blank questions
  static Widget buildBlankInput({
    required TextEditingController controller,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minWidth: 60, maxWidth: 100),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive ? AppColors.darkRed : AppColors.mediumGrey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isActive 
              ? AppColors.darkRed.withOpacity(0.05) 
              : AppColors.white,
        ),
        child: Center(
          child: Text(
            controller.text.isEmpty ? '___' : controller.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: controller.text.isEmpty 
                  ? AppColors.mediumGrey 
                  : AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }

  /// Build question text with interactive blanks for fill-in-the-blank
  static Widget buildQuestionWithBlanks({
    required String questionText,
    required Map<int, TextEditingController> controllers,
    required int? activeBlank,
    required Function(int) onBlankTap,
  }) {
    final parts = <InlineSpan>[];
    // Updated regex to match [0], [1], [2], [3] OR [?]
    final regex = RegExp(r'(\[\d\]|\[\?\])|(\$\$[^\$]+\$\$|\$[^\s\$][^\$]*[^\s\$]\$)');
    int lastIndex = 0;
    int questionMarkCounter = 0; // Counter for [?] blanks

    for (final match in regex.allMatches(questionText)) {
      // Add text before match
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: questionText.substring(lastIndex, match.start),
          style: AppFontStyles.bodyLarge,
        ));
      }

      final matchedText = match.group(0)!;

      // Handle blank [0], [1], [2], [3] OR [?]
      if (matchedText.startsWith('[') && matchedText.endsWith(']')) {
        int blankNum;
        
        if (matchedText == '[?]') {
          // Map [?] to sequential numbers
          blankNum = questionMarkCounter;
          questionMarkCounter++;
        } else {
          // Parse numbered blank [0], [1], etc.
          blankNum = int.parse(
            matchedText.substring(1, matchedText.length - 1)
          );
        }
        
        if (controllers.containsKey(blankNum)) {
          parts.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: buildBlankInput(
              controller: controllers[blankNum]!,
              isActive: activeBlank == blankNum,
              onTap: () => onBlankTap(blankNum),
            ),
          ));
        }
      }
      // Handle LaTeX math using existing MathTextUtils
      else if (matchedText.contains(r'$')) {
        final mathContent = matchedText
            .replaceAll(r'$$', '')
            .replaceAll(r'$', '')
            .trim();
        
        if (MathTextUtils.looksLikeMath(mathContent)) {
          parts.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MathTextUtils.buildOptionText(matchedText),
          ));
        } else {
          parts.add(TextSpan(
            text: matchedText,
            style: AppFontStyles.bodyLarge,
          ));
        }
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < questionText.length) {
      parts.add(TextSpan(
        text: questionText.substring(lastIndex),
        style: AppFontStyles.bodyLarge,
      ));
    }

    return RichText(
      text: TextSpan(
        children: parts.isEmpty 
            ? [TextSpan(text: questionText, style: AppFontStyles.bodyLarge)] 
            : parts,
      ),
    );
  }
}