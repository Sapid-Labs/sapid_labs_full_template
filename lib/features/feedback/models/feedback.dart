import 'package:json_annotation/json_annotation.dart';

part 'feedback.g.dart';

enum FeedbackType {
  bug,
  feature,
  other,
}

@JsonSerializable()
class Feedback {
  String? id;
  String content;
  String? userId;
  FeedbackType? type;
  DateTime? createdAt;

  Feedback({
    this.id,
    required this.content,
    this.userId,
    this.type,
    this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) =>
      _$FeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackToJson(this);
}
