import 'package:flutter/material.dart';
import '../models/quiz_history_item.dart';

class HistoryDetailsPage extends StatelessWidget {
  final QuizHistoryItem quizItem;

  const HistoryDetailsPage({super.key, required this.quizItem});

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6C7E8),
      appBar: AppBar(
        title: Text(
          quizItem.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizItem.questions.length,
        itemBuilder: (context, index) {
          final question = quizItem.questions[index];
          final arabic = isArabic(question.question);

          final yourAnswerLabel = arabic ? "إجابتك" : "Your Answer";

          final correctAnswerLabel = arabic
              ? "الإجابة الصحيحة"
              : "Correct Answer";

          final notAnswered = arabic ? "لم تتم الإجابة" : "Not answered";

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3B0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Directionality(
              textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
              child: Column(
                crossAxisAlignment: arabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: arabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: arabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: [
                        Text(
                          arabic ? "س${index + 1}" : "Q${index + 1}:",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Flexible(
                          child: Text(
                            question.question,
                            textAlign: arabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...question.options.map((option) {
                    final isCorrectOption = option == question.answer;
                    final isUserSelected = option == question.selectedAnswer;

                    Color textColor = Colors.deepPurple;
                    FontWeight weight = FontWeight.normal;
                    String prefix = "";

                    if (isCorrectOption) {
                      textColor = Colors.green.shade800;
                      weight = FontWeight.bold;
                      prefix = "✓ ";
                    }

                    if (isUserSelected && !isCorrectOption) {
                      textColor = Colors.red;
                      weight = FontWeight.bold;
                      prefix = "✗ ";
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: arabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          arabic ? "$option $prefix" : "$prefix$option",
                          textAlign: arabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: weight,
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 10),

                  Text(
                    "$yourAnswerLabel: ${question.selectedAnswer ?? notAnswered}",
                    textAlign: arabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: question.isCorrect == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "$correctAnswerLabel: ${question.answer}",
                    textAlign: arabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
