# Service Patterns

## Table of Contents
- Service Lifecycle
- Firebase Service Pattern
- Supabase Service Pattern
- Signals in Services
- Real-Time Streams
- Filtered and Paginated Queries
- Error Handling
- Service Registration

## Service Lifecycle

Choose the DI annotation based on service behavior:

| Annotation | When to use |
|---|---|
| `@lazySingleton` | Stateless CRUD, no initialization needed, created on first access |
| `@singleton` | Has `setup()`, maintains streams/subscriptions, caches data |
| `@Injectable(as: Foo)` | Multiple implementations of an abstract interface (e.g., Firebase vs Supabase auth) |

## Firebase Service Pattern

The standard pattern for a Firestore-backed service:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

import '../models/item.dart';

// Signals for this service's state
final itemList = listSignal<Item>([]);
final activeItem = signal<Item?>(null);

@lazySingleton
class ItemService {
  ItemService();

  final firestore = FirebaseFirestore.instance;
  CollectionReference get collection => firestore.collection('items');

  Future<void> loadItems() async {
    try {
      final snapshot = await collection.get();
      itemList.value = snapshot.docs
          .map((doc) => Item.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw ItemException('Failed to load items: $e');
    }
  }

  Future<Item> createItem(Item item) async {
    try {
      final docRef = collection.doc();
      final itemWithId = item.copyWith(id: docRef.id);
      await docRef.set(itemWithId.toJson());
      itemList.value = [...itemList.value, itemWithId];
      return itemWithId;
    } catch (e) {
      throw ItemException('Failed to create item: $e');
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await collection.doc(item.id).update(item.toJson());
      itemList.value = itemList.value
          .map((i) => i.id == item.id ? item : i)
          .toList();
    } catch (e) {
      throw ItemException('Failed to update item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await collection.doc(id).delete();
      itemList.value = itemList.value.where((i) => i.id != id).toList();
    } catch (e) {
      throw ItemException('Failed to delete item: $e');
    }
  }
}
```

Key points:
- Always spread `doc.data()` with `'id': doc.id` so the model captures the Firestore document ID
- Update the signal list after mutations so the UI reactively updates
- Wrap all Firestore calls in try-catch, throw feature-specific exceptions

## Supabase Service Pattern

```dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class ItemService {
  ItemService();

  final supabase = Supabase.instance.client;

  Future<List<Item>> getItems() async {
    try {
      final response = await supabase.from('items').select();
      return (response as List).map((e) => Item.fromJson(e)).toList();
    } catch (e) {
      throw ItemException('Failed to get items: $e');
    }
  }

  Future<Item> createItem(Item item) async {
    try {
      final response = await supabase.from('items').insert(item.toJson()).select().single();
      return Item.fromJson(response);
    } catch (e) {
      throw ItemException('Failed to create item: $e');
    }
  }
}
```

## Signals in Services

Signals are the bridge between services and UI. The pattern is:

1. Declare signals at the top of the service file (not inside the class)
2. Prefix with the service/domain name
3. Use `computed` for derived state

```dart
// Primary signals
final campusList = listSignal<Campus>([]);
final authEmail = signal<String?>(null);

// Computed/derived signals
final filteredCampusList = computed(() {
  final email = authEmail.value;
  if (email == null) return <Campus>[];
  
  final domain = email.split('@').last.toLowerCase();
  if (domain == 'test.edu') return campusList.value;
  
  return campusList.value
      .where((c) => c.emailDomains.contains(domain))
      .toList();
});
```

In the UI, use `Watch` to rebuild when signals change:
```dart
Watch((context) => Text('${filteredCampusList.value.length} campuses'))
```

## Real-Time Streams

For Firestore real-time listeners (used in chat, live updates):

```dart
@singleton
class ChatService {
  StreamSubscription? _messagesSub;

  Future<void> setup() async {
    _messagesSub = firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      messageList.value = snapshot.docs
          .map((doc) => Message.fromJson(doc.data()))
          .toList();
    });
  }

  void dispose() {
    _messagesSub?.cancel();
  }
}
```

## Filtered and Paginated Queries

### Firestore Filtered Query
```dart
Future<List<Item>> getItemsByCategory(String category) async {
  final snapshot = await collection
      .where('category', isEqualTo: category)
      .get();
  return snapshot.docs
      .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
}
```

### Firestore Paginated Query
```dart
DocumentSnapshot? lastDoc;

Future<List<Item>> getNextPage({int pageSize = 20}) async {
  var query = collection.orderBy('createdAt').limit(pageSize);
  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc!);
  }
  final snapshot = await query.get();
  if (snapshot.docs.isNotEmpty) {
    lastDoc = snapshot.docs.last;
  }
  return snapshot.docs
      .map((doc) => Item.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
}
```

## Error Handling

Every feature has its own exception class:

```dart
class ItemException implements Exception {
  ItemException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() =>
      'ItemException: $message${code != null ? " (code: $code)" : ""}';
}
```

Service methods follow this pattern:
```dart
try {
  // operation
} on ItemException {
  rethrow;  // Don't wrap already-typed exceptions
} catch (e) {
  throw ItemException('Failed to do X: $e');
}
```

## Service Registration

After creating a service:

1. Add getter in `lib/app/services.dart`:
```dart
ItemService get itemService => getIt.get<ItemService>();
```

2. If `@singleton` with `setup()`, add init call in `lib/main.dart`:
```dart
await services.itemService.setup();
```

3. Run build_runner to regenerate DI config:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
