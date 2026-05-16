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
    final arabic = quizItem.questions.isNotEmpty
        ? isArabic(quizItem.questions.first.question)
        : false;

    return Directionality(
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3B0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment:
                    arabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q${index + 1}: ${question.question}",
                    textAlign: arabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...question.options.map((option) {
                    final isCorrectOption = option == question.answer;
                    final isUserSelected = option == question.selectedAnswer;

                    Color textColor = Colors.deepPurple;
                    FontWeight weight = FontWeight.normal;

                    if (isCorrectOption) {
                      textColor = Colors.green.shade800;
                      weight = FontWeight.bold;
                    }

                    if (isUserSelected && !isCorrectOption) {
                      textColor = Colors.red;
                      weight = FontWeight.bold;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        isCorrectOption
                            ? "✓ $option"
                            : isUserSelected
                                ? "✗ $option"
                                : option,
                        textAlign:
                            arabic ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                          fontWeight: weight,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  Text(
                    "Your Answer: ${question.selectedAnswer ?? "Not answered"}",
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
                    "Correct Answer: ${question.answer}",
                    textAlign: arabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}