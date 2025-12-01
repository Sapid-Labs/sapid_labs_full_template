// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => $checkedCreate(
      'AppUser',
      json,
      ($checkedConvert) {
        final val = AppUser(
          id: $checkedConvert('id', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String?),
          phoneNumber: $checkedConvert('phone_number', (v) => v as String?),
          firstName: $checkedConvert('first_name', (v) => v as String?),
          lastName: $checkedConvert('last_name', (v) => v as String?),
          username: $checkedConvert('username', (v) => v as String?),
          displayName: $checkedConvert('display_name', (v) => v as String?),
          profileImageUrl:
              $checkedConvert('profile_image_url', (v) => v as String?),
          createdAt: $checkedConvert(
              'created_at', (v) => getDateTimeFromTimestamp(v as Timestamp?)),
          updatedAt: $checkedConvert(
              'updated_at', (v) => getDateTimeFromTimestamp(v as Timestamp?)),
        );
        return val;
      },
      fieldKeyMap: const {
        'phoneNumber': 'phone_number',
        'firstName': 'first_name',
        'lastName': 'last_name',
        'displayName': 'display_name',
        'profileImageUrl': 'profile_image_url',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'username': instance.username,
      'display_name': instance.displayName,
      'profile_image_url': instance.profileImageUrl,
      'created_at': getTimestampFromDateTime(instance.createdAt),
      'updated_at': getTimestampFromDateTime(instance.updatedAt),
    };
