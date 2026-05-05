import 'package:flutter/material.dart';
import '../models/quiz_history_item.dart';

class HistoryDetailsPage extends StatelessWidget {
  final QuizHistoryItem quizItem;

  const HistoryDetailsPage({super.key, required this.quizItem});

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

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3B0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Q${index + 1}: ${question.question}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                ...question.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      option == question.answer
                          ? "✓ $option"
                          : option,
                      style: TextStyle(
                        fontSize: 15,
                        color: option == question.answer
                            ? Colors.green.shade800
                            : Colors.deepPurple,
                        fontWeight: option == question.answer
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Correct Answer: ${question.answer}",
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
    );
  }
}