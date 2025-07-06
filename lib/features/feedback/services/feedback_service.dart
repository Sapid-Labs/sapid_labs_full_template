

import 'package:slapp/features/feedback/models/feedback.dart';

abstract class FeedbackService {
  Future<void> submitFeedback(String feedback, FeedbackType type);

  Future<List<Feedback>> getLatestFeedback();
}
