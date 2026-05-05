import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_history_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> saveQuiz(QuizHistoryItem quiz) async {
    await _db.collection('quizzes').doc(quiz.id).set(quiz.toJson());
  }

  Future<List<QuizHistoryItem>> loadHistory() async {
    final userId = currentUserId;
    if (userId == null) return [];

print("CURRENT USER ID: $userId");

    final snapshot = await _db
        .collection('quizzes')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

        print("DOC COUNT: ${snapshot.docs.length}");

    return snapshot.docs
        .map((doc) => QuizHistoryItem.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteQuiz(String id) async {
    await _db.collection('quizzes').doc(id).delete();
  }

  Future<void> renameQuiz(String id, String newTitle) async {
    await _db.collection('quizzes').doc(id).update({
      'title': newTitle,
    });
  }
}