import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/question.dart';
import 'quiz_service.dart';
import 'quiz_page.dart';
import '../models/quiz_history_item.dart';
import 'firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerateQuizPage extends StatefulWidget {
  const GenerateQuizPage({super.key});

  @override
  State<GenerateQuizPage> createState() => _GenerateQuizPageState();
}

class _GenerateQuizPageState extends State<GenerateQuizPage> {
  String? selectedFilePath;
  String selectedFileName = "No file selected";
  String extractedText = "";
  bool isGenerating = false;

  String selectedDifficulty = "Easy";
  String selectedQuestionType = "Multiple Choice";
  int selectedQuestionCount = 10;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
    );

    if (result != null) {
      final file = result.files.single;

      setState(() {
        selectedFilePath = file.path;
        selectedFileName = file.name;
      });

      if (file.path != null && file.name.toLowerCase().endsWith('.txt')) {
        final text = await File(file.path!).readAsString();

        setState(() {
          extractedText = text;
        });
      } else if (file.path != null &&
          file.name.toLowerCase().endsWith('.pdf')) {
        try {
          final bytes = File(file.path!).readAsBytesSync();
          final document = PdfDocument(inputBytes: bytes);
          final text = PdfTextExtractor(document).extractText();
          document.dispose();

          setState(() {
            extractedText = text;
          });

          if (text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "PDF was selected, but no readable text was found.",
                ),
              ),
            );
          }
        } catch (e) {
          setState(() {
            extractedText = "";
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to read PDF: $e")));
        }
      } else {
        setState(() {
          extractedText = "";
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unsupported file type.")));
      }
    }
  }

  Future<void> generateQuiz() async {
    if (selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose a file first")),
      );
      return;
    }

    if (extractedText.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No text found")));
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      final List<Question> questions =
          await QuizService.generateQuestionsWithAI(
            text: extractedText,
            difficulty: selectedDifficulty,
            questionType: selectedQuestionType,
            questionCount: selectedQuestionCount,
          );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("No logged-in user found.");
      }

      final historyItem = QuizHistoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        title: selectedFileName == "No file selected"
            ? "Quiz ${DateTime.now().day}/${DateTime.now().month}"
            : selectedFileName,
        fileName: selectedFileName,
        difficulty: selectedDifficulty,
        questionType: selectedQuestionType,
        questionCount: selectedQuestionCount,
        createdAt: DateTime.now(),
        questions: questions,
      );

      print("HISTORY ITEM JSON: ${historyItem.toJson()}");

      await FirestoreService().saveQuiz(historyItem);

      if (!mounted) return;

      setState(() {
        isGenerating = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizPage(questions: questions)),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isGenerating = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6C7E8),
      appBar: AppBar(
        title: const Text("Generate Quiz"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload Lecture Notes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Upload a TXT or PDF file to generate quiz questions.",
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3B0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.upload_file,
                    size: 60,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    selectedFileName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text("Choose File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6C7E8),
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            buildSectionTitle("Type of Questions"),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3B0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedQuestionType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFFF3F3B0),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Multiple Choice",
                      child: Text("Multiple Choice"),
                    ),
                    DropdownMenuItem(
                      value: "True-False",
                      child: Text("True-False"),
                    ),
                    DropdownMenuItem(value: "Both", child: Text("Both")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedQuestionType = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildSectionTitle("Number of Questions"),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3B0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: selectedQuestionCount,
                  isExpanded: true,
                  dropdownColor: const Color(0xFFF3F3B0),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                  ),
                  items: [10, 15, 20, 25, 30].map((number) {
                    return DropdownMenuItem(
                      value: number,
                      child: Text(number.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedQuestionCount = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildSectionTitle("Difficulty"),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3B0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDifficulty,
                  isExpanded: true,
                  dropdownColor: const Color(0xFFF3F3B0),
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                  ),
                  items: const [
                    DropdownMenuItem(value: "Easy", child: Text("Easy")),
                    DropdownMenuItem(value: "Medium", child: Text("Medium")),
                    DropdownMenuItem(value: "Hard", child: Text("Hard")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDifficulty = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (extractedText.isNotEmpty) ...[
              buildSectionTitle("Extracted Text"),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3B0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      extractedText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ] else
              const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isGenerating ? null : generateQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F3B0),
                  foregroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Generate Quiz",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
