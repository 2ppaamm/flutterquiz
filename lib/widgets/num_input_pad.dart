import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_font_styles.dart';
import '../theme/app_input_styles.dart';

class NumInputPad extends StatelessWidget {
  final String userInput;
  final Function(String) onChanged;

  const NumInputPad({
    Key? key,
    required this.userInput,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '.',
      '0',
      '←'
    ];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: TextField(
            controller: TextEditingController(text: userInput),
            readOnly: true,
            style: AppFontStyles.questionText,
            decoration: AppInputStyles.type2primary.copyWith(
              hintText: 'Pop your answer in here!',
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          physics: const NeverScrollableScrollPhysics(),
          children: buttons.map((char) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                padding: const EdgeInsets.all(3),
                minimumSize: const Size(48, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.56),
                ),
              ),
              onPressed: () {
                String updated = userInput;
                if (char == '←') {
                  if (updated.isNotEmpty) {
                    updated = updated.substring(0, updated.length - 1);
                  }
                } else {
                  updated += char;
                }
                onChanged(updated);
              },
              child: Text(char, style: AppFontStyles.inputPad),
            );
          }).toList(),
        ),
      ],
    );
  }
}
