import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/feedback_model.dart';

class FeedbackRepository {
  final FirebaseFirestore _firestore;

  FeedbackRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> submitFeedback(FeedbackModel feedback) async {
    await _firestore.collection('feedback').add(feedback.toMap());
  }
}
