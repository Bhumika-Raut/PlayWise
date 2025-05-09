class Question {
  final String id;
  final String type; 
  final String text;
  final List<String> options;
  final String correctAnswer;
  final String? imagePath;
  final String? audioPath;
  final List<String>? words;

  Question({
    required this.id,
    required this.type,
    required this.text,
    required this.options,
    required this.correctAnswer,
    this.imagePath,
    this.audioPath,
    this.words,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      words: json['words'] != null ? List<String>.from(json['words']) : null,
    );
  }
}