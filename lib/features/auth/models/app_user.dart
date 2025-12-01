import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser {
  @JsonKey(includeIfNull: false)
  final String id;
  final String? email;

  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;

  @JsonKey(
    name: 'created_at',
    fromJson: getDateTimeFromTimestamp,
    toJson: getTimestampFromDateTime,
  )
  final DateTime? createdAt;

  @JsonKey(
    name: 'updated_at',
    fromJson: getDateTimeFromTimestamp,
    toJson: getTimestampFromDateTime,
  )
  final DateTime? updatedAt;

  AppUser({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.username,
    this.displayName,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  // Computed properties
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName ?? email ?? '';
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? username,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime? getDateTimeFromTimestamp(Timestamp? value) {
  if (value == null) return null;
  return value.toDate();
}

Timestamp? getTimestampFromDateTime(DateTime? value) {
  if (value == null) return null;
  return Timestamp.fromDate(value);
}
