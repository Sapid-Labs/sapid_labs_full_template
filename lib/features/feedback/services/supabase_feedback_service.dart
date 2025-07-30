import 'package:injectable/injectable.dart';
import 'package:slapp/app/get_it.dart';
import 'package:slapp/features/auth/services/auth_service.dart';
import 'package:slapp/features/feedback/models/feedback.dart';
import 'package:slapp/features/feedback/services/feedback_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@supabaseEnv
@LazySingleton(as: FeedbackService)
class SupabaseFeedbackService extends FeedbackService {
  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<List<Feedback>> getLatestFeedback() async {
    List<Map<String, dynamic>> response = await _supabase
        .from('feedback')
        .select('*')
        .order('created_at', ascending: false)
        .limit(10);

    if (response.isEmpty) return [];
    return (response).map((e) => Feedback.fromJson(e)).toList();
  }

  @override
  Future<void> submitFeedback(String feedback, FeedbackType type) async {
    return _supabase.from('feedback').insert(Feedback(
          userId: authUserId.value,
          createdAt: DateTime.now(),
          content: feedback,
          type: type,
        ).toJson());
  }
}
