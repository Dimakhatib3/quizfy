class Question {
  final String question;
  final List<String> options;
  final String answer;


  String? selectedAnswer;
  bool? isCorrect;

  Question({
    required this.question,
    required this.options,
    required this.answer,
    this.selectedAnswer,
    this.isCorrect,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    List<String> parsedOptions = [];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList();
    }

    return Question(
      question: (json['question'] ?? '').toString(),
      options: parsedOptions,
      answer: (json['answer'] ?? json['correctAnswer'] ?? '').toString(),

  
      selectedAnswer: json['selectedAnswer'],
      isCorrect: json['isCorrect'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,


      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
    };
  }
}