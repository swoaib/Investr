class FeedbackModel {
  final String content;
  final String? email;
  final DateTime timestamp;

  FeedbackModel({required this.content, required this.timestamp, this.email});

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'email': email,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
