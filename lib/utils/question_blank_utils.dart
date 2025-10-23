/// Utility functions for fill-in-the-blank questions
class QuestionBlankUtils {
  /// Extract blank positions from question text [0], [1], [2], [3] OR [?]
  static List<int> extractBlanks(String questionText) {
    // First try numbered blanks [0], [1], [2], [3]
    final numberedRegex = RegExp(r'\[(\d)\]');
    final numberedMatches = numberedRegex.allMatches(questionText);
    if (numberedMatches.isNotEmpty) {
      return numberedMatches.map((m) => int.parse(m.group(1)!)).toList();
    }
    
    // If no numbered blanks, count [?] and assign sequential numbers
    final questionMarkRegex = RegExp(r'\[\?\]');
    final questionMarkMatches = questionMarkRegex.allMatches(questionText);
    return List.generate(questionMarkMatches.length, (index) => index);
  }
  
  /// Check if question has blanks ([0], [1], [2], [3] OR [?])
  static bool hasBlanks(String questionText) {
    return questionText.contains(RegExp(r'\[\d\]')) || 
           questionText.contains('[?]');
  }
  
  /// Get number of blanks (0-4)
  static int countBlanks(String questionText) {
    return extractBlanks(questionText).length;
  }
  
  /// Validate user answers against correct answers
  static bool validateAnswers(
    Map<int, String> userAnswers,
    Map<String, String?> correctAnswers,
  ) {
    for (int i = 0; i < 4; i++) {
      final key = 'answer$i';
      final correctAnswer = correctAnswers[key];
      
      // Only validate if correct answer exists and is not empty
      if (correctAnswer != null && correctAnswer.isNotEmpty) {
        final userAnswer = userAnswers[i]?.trim() ?? '';
        if (userAnswer != correctAnswer.trim()) {
          return false;
        }
      }
    }
    return true;
  }
}