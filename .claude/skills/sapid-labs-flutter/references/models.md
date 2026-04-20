# Model Patterns

## Table of Contents
- Standard Model Template
- Firestore ID Handling
- Nullable Fields and Defaults
- Computed/Derived Fields
- List Fields with Null Safety
- Enum Fields
- Timestamp Handling

## Standard Model Template

Every model follows this exact pattern:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

/// Description of what this model represents
@JsonSerializable()
class Item {
  Item({
    this.id,
    required this.name,
    this.description,
    this.tags = const [],
    this.createdAt,
  });

  final String? id;
  final String name;
  final String? description;
  final List<String> tags;
  final DateTime? createdAt;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  Item copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Item(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

Key conventions:
- `id` is always `String?` (null before first save)
- Required fields use `required` in constructor
- List fields default to `const []`
- Always include `copyWith`, `toString`, equality based on `id`

## Firestore ID Handling

Firestore document IDs are NOT stored inside the document data. You need to merge them when reading:

```dart
// In the service
final doc = await collection.doc(id).get();
return Item.fromJson({
  ...doc.data() as Map<String, dynamic>,
  'id': doc.id,
});

// For queries
final snapshot = await collection.get();
return snapshot.docs
    .map((doc) => Item.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        }))
    .toList();
```

When writing, exclude the `id` field or let Firestore use the doc reference:
```dart
final docRef = collection.doc();
final itemWithId = item.copyWith(id: docRef.id);
await docRef.set(itemWithId.toJson());
```

## Nullable Fields and Defaults

When a field might not exist in older Firestore documents (schema evolution), handle it gracefully in the generated code or with `@JsonKey`:

```dart
@JsonKey(defaultValue: [])
final List<String> emailDomains;

@JsonKey(name: 'created_at')
final DateTime? createdAt;

@JsonKey(includeIfNull: false)
final String? optionalField;
```

If you need to manually update `.g.dart` files (e.g., when build_runner isn't available), the null-safe pattern for lists is:
```dart
emailDomains: (json['emailDomains'] as List<dynamic>?)
    ?.map((e) => e as String)
    .toList() ?? const [],
```

## List Fields with Null Safety

Firestore can return `null` for fields that don't exist yet. Always handle this:

```dart
// In the model
final List<String> tags;

// Constructor default
Item({this.tags = const []});

// In .g.dart (what build_runner generates)
tags: (json['tags'] as List<dynamic>?)
    ?.map((e) => e as String)
    .toList() ?? const [],
```

## Enum Fields

Use `@JsonEnum` for enum serialization:

```dart
@JsonEnum(valueField: 'value')
enum UserRole {
  admin('admin'),
  parent('parent'),
  sitter('sitter');

  const UserRole(this.value);
  final String value;
}

// In the model
@JsonKey(unknownEnumValue: UserRole.parent)
final UserRole role;
```

The `unknownEnumValue` prevents crashes when the DB contains a value the app doesn't recognize yet (forward compatibility).

## Timestamp Handling

Firestore Timestamps need special handling:

```dart
// Option 1: Use DateTime with a custom converter
@JsonKey(
  fromJson: _timestampToDateTime,
  toJson: _dateTimeToTimestamp,
)
final DateTime? createdAt;

static DateTime? _timestampToDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.parse(value);
  return null;
}

static dynamic _dateTimeToTimestamp(DateTime? value) {
  if (value == null) return null;
  return Timestamp.fromDate(value);
}
```

```dart
// Option 2: Use FieldValue.serverTimestamp() for creation
await docRef.set({
  ...item.toJson(),
  'createdAt': FieldValue.serverTimestamp(),
});
```
