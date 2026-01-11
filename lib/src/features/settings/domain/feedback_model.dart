class FeedbackModel {
  final String content;
  final String? name;
  final String? email;
  final DateTime timestamp;

  FeedbackModel({
    required this.content,
    this.name,
    this.email,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'name': name,
      'email': email,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
