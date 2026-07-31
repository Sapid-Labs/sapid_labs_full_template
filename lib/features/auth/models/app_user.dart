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

/// Timestamp conversion that does not name a vendor type.
///
/// These two used to take and return a `cloud_firestore` `Timestamp`, so
/// `AppUser` -- a model every child app uses -- imported the Firestore SDK and
/// pinned the whole template to Firebase. A Supabase or Pocketbase app reading a
/// real row through this model threw a cast error on the first profile it loaded.
///
/// The Firestore shape is still handled, by duck typing rather than by an import:
/// a `Timestamp` answers `toDate()`. Writing goes out as ISO 8601 in every case,
/// which Firestore stores as a string rather than as a native timestamp -- worth
/// knowing if you want to range-query `created_at` server side there.
///
/// Parsing is tolerant on purpose. A malformed or absent value yields null rather
/// than throwing, because a profile is still usable without knowing its dates.
DateTime? getDateTimeFromTimestamp(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  try {
    final dynamic candidate = value;
    final Object? converted = candidate.toDate();
    if (converted is DateTime) return converted;
  } catch (_) {
    // Not a Firestore Timestamp. Fall through to null.
  }
  return null;
}

String? getTimestampFromDateTime(DateTime? value) =>
    value?.toUtc().toIso8601String();
