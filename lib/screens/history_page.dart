import 'package:flutter/material.dart';
import '../models/quiz_history_item.dart';
import 'firestore_service.dart';
import 'history_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<QuizHistoryItem> history = [];
  List<QuizHistoryItem> filteredHistory = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
    searchController.addListener(filterHistory);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadHistory() async {
    final loaded = await FirestoreService().loadHistory();

    setState(() {
      history = loaded;
      filteredHistory = loaded;
      isLoading = false;
    });
  }

  void filterHistory() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredHistory = history;
        return;
      }

      List<QuizHistoryItem> results = history.where((item) {
        final title = item.title.toLowerCase();
        final difficulty = item.difficulty.toLowerCase();
        final type = item.questionType.toLowerCase();
        final fileName = item.fileName.toLowerCase();
        final date =
            "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}";

        final language =
            item.questions.isNotEmpty &&
                    isArabic(item.questions.first.question)
                ? "arabic"
                : "english";

        bool matches = true;

        // SMART DIFFICULTY
        if (query.contains("most difficult") ||
            query.contains("hardest") ||
            query.contains("hard")) {
          final hasHard =
              history.any((q) => q.difficulty.toLowerCase() == "hard");
          final hasMedium =
              history.any((q) => q.difficulty.toLowerCase() == "medium");

          if (hasHard) {
            matches = matches && difficulty == "hard";
          } else if (hasMedium) {
            matches = matches && difficulty == "medium";
          } else {
            matches = matches && difficulty == "easy";
          }
        }

        if (query.contains("easiest") ||
            query.contains("easy") ||
            query.contains("simple")) {
          final hasEasy =
              history.any((q) => q.difficulty.toLowerCase() == "easy");
          final hasMedium =
              history.any((q) => q.difficulty.toLowerCase() == "medium");

          if (hasEasy) {
            matches = matches && difficulty == "easy";
          } else if (hasMedium) {
            matches = matches && difficulty == "medium";
          } else {
            matches = matches && difficulty == "hard";
          }
        }

        if (query.contains("medium")) {
          matches = matches && difficulty == "medium";
        }

        // SMART DATE
        final now = DateTime.now();

        if (query.contains("today")) {
          matches = matches &&
              item.createdAt.day == now.day &&
              item.createdAt.month == now.month &&
              item.createdAt.year == now.year;
        }

        if (query.contains("yesterday")) {
          final yesterday = now.subtract(const Duration(days: 1));

          matches = matches &&
              item.createdAt.day == yesterday.day &&
              item.createdAt.month == yesterday.month &&
              item.createdAt.year == yesterday.year;
        }

        if (query.contains("this week")) {
          final daysDifference = now.difference(item.createdAt).inDays;
          matches = matches && daysDifference <= 7;
        }

        if (query.contains("this month")) {
          matches = matches &&
              item.createdAt.month == now.month &&
              item.createdAt.year == now.year;
        }

        // LANGUAGE
        if (query.contains("arabic")) {
          matches = matches && language == "arabic";
        }

        if (query.contains("english")) {
          matches = matches && language == "english";
        }

        // TYPE
        if (query.contains("true false") || query.contains("tf")) {
          matches = matches && type.contains("true");
        }

        if (query.contains("multiple choice") || query.contains("mcq")) {
          matches = matches && type.contains("multiple");
        }

        if (query.contains("both")) {
          matches = matches && type.contains("both");
        }

        // EXACT DATE
        if (RegExp(r'\d{1,2}/\d{1,2}/\d{4}').hasMatch(query)) {
          matches = matches && date.contains(query);
        }

        final generalMatch =
            title.contains(query) ||
            fileName.contains(query) ||
            date.contains(query);

        return matches &&
            (generalMatch ||
                query.contains("hard") ||
                query.contains("hardest") ||
                query.contains("most difficult") ||
                query.contains("easy") ||
                query.contains("easiest") ||
                query.contains("simple") ||
                query.contains("medium") ||
                query.contains("today") ||
                query.contains("yesterday") ||
                query.contains("this week") ||
                query.contains("this month") ||
                query.contains("arabic") ||
                query.contains("english") ||
                query.contains("true false") ||
                query.contains("tf") ||
                query.contains("multiple choice") ||
                query.contains("mcq") ||
                query.contains("both") ||
                query.contains("latest") ||
                query.contains("recent") ||
                query.contains("oldest"));
      }).toList();

      // SMART SORTING
      if (query.contains("latest") || query.contains("recent")) {
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      if (query.contains("oldest")) {
        results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

      filteredHistory = results;
    });
  }

  Future<void> deleteQuiz(String id) async {
    await FirestoreService().deleteQuiz(id);
    await loadHistory();
  }

  Future<void> renameQuiz(QuizHistoryItem item) async {
    final controller = TextEditingController(text: item.title);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Quiz"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter new name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = controller.text.trim();

              if (newTitle.isNotEmpty) {
                await FirestoreService().renameQuiz(item.id, newTitle);
                if (!mounted) return;
                Navigator.pop(context);
                await loadHistory();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Color getTypeColor(String type) {
    if (type == "Multiple Choice") {
      return Colors.deepPurple;
    } else if (type == "True-False") {
      return Colors.teal;
    } else {
      return Colors.orange;
    }
  }

  Widget buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildQuizCard(QuizHistoryItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryDetailsPage(quizItem: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3B0),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.deepPurple.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.quiz_rounded,
                color: Colors.deepPurple,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      buildInfoChip(
                        item.questionType,
                        getTypeColor(item.questionType),
                      ),
                      buildInfoChip(item.difficulty, Colors.pink),
                      buildInfoChip(
                        "${item.questions.length} Questions",
                        Colors.indigo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "File: ${item.fileName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Saved on ${formatDate(item.createdAt)}",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap to view questions and answers",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.deepPurple,
              ),
              onSelected: (value) async {
                if (value == "rename") {
                  await renameQuiz(item);
                } else if (value == "delete") {
                  await deleteQuiz(item.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "rename",
                  child: Text("Rename"),
                ),
                PopupMenuItem(
                  value: "delete",
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6C7E8),
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText:
                            "Search by title, date, difficulty, language...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF3F3B0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredHistory.isEmpty
                        ? const Center(
                            child: Text(
                              "No quizzes found.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredHistory.length,
                            itemBuilder: (context, index) {
                              return buildQuizCard(filteredHistory[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}