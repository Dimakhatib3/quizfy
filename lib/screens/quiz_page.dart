import 'package:flutter/material.dart';
import '../models/question.dart';
import 'firestore_service.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final String quizId;

  const QuizPage({
    super.key,
    required this.questions,
    required this.quizId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;

  late List<String?> selectedAnswers;
  late List<List<String>> shuffledOptions;

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  void initState() {
    super.initState();

    selectedAnswers = List<String?>.filled(widget.questions.length, null);

    shuffledOptions = widget.questions.map((q) {
      final options = List<String>.from(q.options);
      options.shuffle();
      return options;
    }).toList();
  }

  void selectAnswer(String option) {
    setState(() {
      selectedAnswers[currentIndex] = option;

      widget.questions[currentIndex].selectedAnswer = option;
      widget.questions[currentIndex].isCorrect =
          option == widget.questions[currentIndex].answer;
    });
  }

  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      showSubmitDialog();
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  int calculateScore() {
    int score = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      if (selectedAnswers[i] == widget.questions[i].answer) {
        score++;
      }
    }

    return score;
  }

  int answeredCount() {
    return selectedAnswers.where((e) => e != null).length;
  }

  void showSubmitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Finish Quiz?"),
        content: Text(
          "You answered ${answeredCount()} / ${widget.questions.length}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showResult();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void showResult() async {
    final score = calculateScore();

    await FirestoreService().updateQuizQuestions(
      widget.quizId,
      widget.questions,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text("Score: $score / ${widget.questions.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];
    final selected = selectedAnswers[currentIndex];
    final options = shuffledOptions[currentIndex];
    final arabic = isArabic(question.question);

    return Directionality(
      textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFE6C7E8),
        appBar: AppBar(
          title: const Text("Quiz"),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                arabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                "Question ${currentIndex + 1} / ${widget.questions.length}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Answered: ${answeredCount()}",
                style: const TextStyle(color: Colors.deepPurple),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3B0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question.question,
                  textAlign: arabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selected == option;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(0.15)
                            : const Color(0xFFF3F3B0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: option,
                        groupValue: selected,
                        onChanged: (value) {
                          if (value != null) {
                            selectAnswer(value);
                          }
                        },
                        activeColor: Colors.deepPurple,
                        title: Text(
                          option,
                          textAlign:
                              arabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          currentIndex == 0 ? null : previousQuestion,
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextQuestion,
                      child: Text(
                        currentIndex == widget.questions.length - 1
                            ? "Finish"
                            : "Next",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}