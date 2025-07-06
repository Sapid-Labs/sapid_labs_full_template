import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/feedback/models/feedback.dart';

import 'feedback_service.dart';

@pocketbase
@LazySingleton(as: FeedbackService)
class PocketbaseFeedbackService extends FeedbackService {
  PocketBase pb = PocketBase(const String.fromEnvironment('POCKETBASE_URL'));

  @override
  Future<List<Feedback>> getLatestFeedback() async {
    debugPrint('getLatestFeedback');
    ResultList<RecordModel> results = await pb.collection('feedback').getList();
    debugPrint('results: ' + results.toString());

    return results.items.map((e) => Feedback.fromJson(e.toJson())).toList();
  }

  @override
  Future<void> submitFeedback(String feedback, FeedbackType type) async {
    try {
      Feedback newFeedback = Feedback(
        userId: authUserId.value,
        content: feedback,
        type: type,
        createdAt: DateTime.now(),
      );
      await pb.collection('feedback').create(body: newFeedback.toJson());
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
