import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_history_item.dart';

class HistoryStorage {
  static const String historyKey = 'quiz_history';

  static Future<List<QuizHistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedList = prefs.getStringList(historyKey) ?? [];

    return savedList
        .map((item) => QuizHistoryItem.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> saveHistory(List<QuizHistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(historyKey, encoded);
  }

  static Future<void> addQuiz(QuizHistoryItem quiz) async {
    final history = await loadHistory();
    history.insert(0, quiz);
    await saveHistory(history);
  }

  static Future<void> deleteQuiz(String id) async {
    final history = await loadHistory();
    history.removeWhere((item) => item.id == id);
    await saveHistory(history);
  }

  static Future<void> renameQuiz(String id, String newTitle) async {
    final history = await loadHistory();
    final index = history.indexWhere((item) => item.id == id);

    if (index != -1) {
      history[index] = history[index].copyWith(title: newTitle);
      await saveHistory(history);
    }
  }
}