import 'question.dart';

class QuizHistoryItem {
  final String id;
  final String userId;
  final String title;
  final String fileName;
  final String difficulty;
  final String questionType;
  final int questionCount;
  final DateTime createdAt;
  final List<Question> questions;

  QuizHistoryItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.fileName,
    required this.difficulty,
    required this.questionType,
    required this.questionCount,
    required this.createdAt,
    required this.questions,
  });

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) {
    return QuizHistoryItem(
      id: json['id'],
      userId: json['userId'] ?? '',
      title: json['title'],
      fileName: json['fileName'],
      difficulty: json['difficulty'],
      questionType: json['questionType'],
      questionCount: json['questionCount'],
      createdAt: DateTime.parse(json['createdAt']),
      questions: (json['questions'] as List)
          .map((item) => Question.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'fileName': fileName,
      'difficulty': difficulty,
      'questionType': questionType,
      'questionCount': questionCount,
      'createdAt': createdAt.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  QuizHistoryItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? fileName,
    String? difficulty,
    String? questionType,
    int? questionCount,
    DateTime? createdAt,
    List<Question>? questions,
  }) {
    return QuizHistoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      difficulty: difficulty ?? this.difficulty,
      questionType: questionType ?? this.questionType,
      questionCount: questionCount ?? this.questionCount,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
    );
  }
}