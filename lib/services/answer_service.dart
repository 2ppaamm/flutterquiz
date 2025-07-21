class AnswerService {
  static bool checkMCQAnswer(Map<String, dynamic> question, String? selectedOption) {
    if (selectedOption == null) return false;

    int correctIndex = question['correct_answer'];
    int? selectedIndex;

    for (int i = 0; i < 4; i++) {
      if (selectedOption == question['answer$i']) {
        selectedIndex = i;
        break;
      }
    }

    return selectedIndex == correctIndex;
  }

  static Map<String, dynamic> checkFIBNumbers(
      Map<String, dynamic> question, Map<int, String?> userInputs) {
    bool allCorrect = true;
    List<String?> answers = List.filled(4, null);

    for (int i = 0; i < 4; i++) {
      final correctRaw = question['answer$i'];
      final userRaw = userInputs[i];

      if (correctRaw == null || correctRaw.toString().trim().isEmpty) continue;

      final correctStr = correctRaw.toString().trim();
      final userStr = userRaw?.trim() ?? '';
      answers[i] = userStr;

      if (userStr.isEmpty) {
        allCorrect = false;
        print('Missing answer at index $i');
        continue;
      }

      final correctNum = double.tryParse(correctStr);
      final inputNum = double.tryParse(userStr);

      if (correctNum != null && inputNum != null) {
        if (correctNum != inputNum) {
          allCorrect = false;
          print('Incorrect number at index $i: $inputNum != $correctNum');
        } else {
          print('Correct number at index $i');
        }
      } else {
        if (userStr != correctStr) {
          allCorrect = false;
          print('Incorrect text at index $i: "$userStr" != "$correctStr"');
        } else {
          print('Correct text at index $i');
        }
      }
    }

    print('Final result: isCorrect = $allCorrect');

    return {
      'isCorrect': allCorrect,
      'answers': answers,
    };
  }
}