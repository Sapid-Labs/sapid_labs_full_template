// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feedback _$FeedbackFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Feedback',
      json,
      ($checkedConvert) {
        final val = Feedback(
          id: $checkedConvert('id', (v) => v as String?),
          content: $checkedConvert('content', (v) => v as String),
          userId: $checkedConvert('userId', (v) => v as String?),
          type: $checkedConvert(
              'type', (v) => $enumDecodeNullable(_$FeedbackTypeEnumMap, v)),
          createdAt: $checkedConvert('createdAt',
              (v) => v == null ? null : DateTime.parse(v as String)),
        );
        return val;
      },
    );

Map<String, dynamic> _$FeedbackToJson(Feedback instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'userId': instance.userId,
      'type': _$FeedbackTypeEnumMap[instance.type],
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.bug: 'bug',
  FeedbackType.feature: 'feature',
  FeedbackType.other: 'other',
};
