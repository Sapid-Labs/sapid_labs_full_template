import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:injectable/injectable.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/feedback/models/feedback.dart';
import 'package:slapp/features/feedback/services/feedback_service.dart';

@firebase
@LazySingleton(as: FeedbackService)
class FirebaseFeedbackService extends FeedbackService {
  @override
  Future<void> submitFeedback(String feedback, FeedbackType type) async {
    DocumentReference feedbackDoc =
        FirebaseFirestore.instance.collection('feedback').doc();

    await feedbackDoc.set(Feedback(
      id: feedbackDoc.id,
      userId: authUserId.value,
      createdAt: DateTime.now(),
      content: feedback,
      type: type,
    ).toJson());
  }

  @override
  Future<List<Feedback>> getLatestFeedback() {
    return FirebaseFirestore.instance
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get()
        .then((value) =>
            value.docs.map((e) => Feedback.fromJson(e.data())).toList());
  }
}
