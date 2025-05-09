class ApiResponse {
  final List<Question> questions;
  final String? error;

  ApiResponse({
    required this.questions,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      error: json['error'], 
    );
  }

  factory ApiResponse.withError(String error) {
    return ApiResponse(questions: [], error: error);
  }
}
