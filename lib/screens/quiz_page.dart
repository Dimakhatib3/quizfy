import 'package:flutter/material.dart';
import '../models/question.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;

  const QuizPage({super.key, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;

  late List<String?> selectedAnswers;
  late List<List<String>> shuffledOptions;

  @override
  void initState() {
    super.initState();

    selectedAnswers = List<String?>.filled(widget.questions.length, null);

    // Shuffle options ONCE
    shuffledOptions = widget.questions.map((q) {
      final options = List<String>.from(q.options);
      options.shuffle();
      return options;
    }).toList();
  }

  void selectAnswer(String option) {
    setState(() {
      selectedAnswers[currentIndex] = option;
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

  void showResult() {
    final score = calculateScore();

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

    return Scaffold(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top info
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

            // Question box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3B0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Options
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        currentIndex == 0 ? null : previousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F3B0),
                      foregroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      currentIndex == widget.questions.length - 1
                          ? "Finish"
                          : "Skip / Next",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}