import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuizService {
  static const String functionUrl =
      'https://generatequiz-lpivjqyrga-uc.a.run.app';

  static Future<List<Question>> generateQuestionsWithAI({
    required String text,
    required String difficulty,
    required String questionType,
    required int questionCount,
  }) async {
    final url = Uri.parse(functionUrl);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "text": text,
        "difficulty": difficulty,
        "questionType": questionType,
        "questionCount": questionCount,
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        "Server error: ${response.statusCode}\n${response.body}",
      );
    }

    final decoded = _safeDecode(response.body);
    final questionsList = _extractQuestions(decoded);

    if (questionsList.isEmpty) {
      throw Exception("No questions found in server response.");
    }

    return questionsList.map((item) => Question.fromJson(item)).toList();
  }

  static dynamic _safeDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      final cleaned = _removeCodeFences(body.trim());

      try {
        return jsonDecode(cleaned);
      } catch (_) {
        throw Exception("Response is not valid JSON.\nBody was:\n$body");
      }
    }
  }

  static String _removeCodeFences(String text) {
    String result = text;

    if (result.startsWith('```json')) {
      result = result.replaceFirst('```json', '').trim();
    } else if (result.startsWith('```')) {
      result = result.replaceFirst('```', '').trim();
    }

    if (result.endsWith('```')) {
      result = result.substring(0, result.length - 3).trim();
    }

    return result;
  }

  static List<Map<String, dynamic>> _extractQuestions(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    if (decoded is Map<String, dynamic>) {
      if (decoded['questions'] is List) {
        return (decoded['questions'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }

      if (decoded['quiz'] is List) {
        return (decoded['quiz'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }

      if (decoded['data'] is Map<String, dynamic>) {
        final data = decoded['data'] as Map<String, dynamic>;

        if (data['questions'] is List) {
          return (data['questions'] as List)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }

    return [];
  }
}