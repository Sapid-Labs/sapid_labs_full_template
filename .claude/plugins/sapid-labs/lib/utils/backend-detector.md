# Backend Detector Utility

This document provides guidance for detecting the active backend implementation in the Sapid Labs Flutter template project.

## Purpose

The backend detector analyzes existing service implementations to determine which backend (Firebase, Supabase, or Pocketbase) is actively used in the codebase. This ensures new services are generated with the correct backend implementation pattern.

## Detection Strategy

### Step 1: Scan Existing Services

Search for service files in the codebase:
```
lib/features/*/services/*.dart
```

### Step 2: Analyze Implementation Patterns

Look for backend-specific indicators in service files:

#### Firebase Indicators
- Import statements: `import 'package:firebase_auth/firebase_auth.dart'`
- Import statements: `import 'package:cloud_firestore/cloud_firestore.dart'`
- Class usage: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`
- Method calls: `FirebaseAuth.instance`, `FirebaseFirestore.instance`
- Collection references: `.collection()`, `.doc()`
- Firebase-specific types: `DocumentReference`, `CollectionReference`, `DocumentSnapshot`

#### Supabase Indicators
- Import statements: `import 'package:supabase_flutter/supabase_flutter.dart'`
- Class usage: `SupabaseClient`, `Supabase`
- Method calls: `Supabase.instance.client`
- Query patterns: `.from()`, `.select()`, `.insert()`, `.update()`
- Auth: `supabase.auth.signIn`, `supabase.auth.currentUser`
- RPC calls: `.rpc()`

#### Pocketbase Indicators
- Import statements: `import 'package:pocketbase/pocketbase.dart'`
- Class usage: `PocketBase`
- Method calls: `pb.collection()`
- Record operations: `.getList()`, `.getOne()`, `.create()`, `.update()`
- Auth: `pb.authStore`, `pb.collection('users').authWithPassword()`

### Step 3: Count Implementations

For each backend type, count the number of service files that use it:
- Firebase count: Number of services with Firebase indicators
- Supabase count: Number of services with Supabase indicators
- Pocketbase count: Number of services with Pocketbase indicators

### Step 4: Determine Primary Backend

The backend with the highest count is the active backend:
- If Firebase count > others: Return `'firebase'`
- If Supabase count > others: Return `'supabase'`
- If Pocketbase count > others: Return `'pocketbase'`

### Step 5: Handle Edge Cases

**No services exist:**
- Check `pubspec.yaml` for backend dependencies
- If `firebase_core` present: Default to `'firebase'`
- If `supabase_flutter` present: Default to `'supabase'`
- If `pocketbase` present: Default to `'pocketbase'`
- If multiple or none: Default to `'firebase'` (most common)

**Tie between backends:**
- Check most recently modified service file
- Use backend from that file
- If still unclear: Default to `'firebase'`

**Mixed implementations:**
- This is unusual but possible
- Use majority backend
- Log warning that mixed backends detected

## Detection Algorithm

```
1. Search for all files matching: lib/features/*/services/*.dart
2. For each service file:
   a. Read file contents
   b. Check for Firebase indicators → increment firebase_count
   c. Check for Supabase indicators → increment supabase_count
   d. Check for Pocketbase indicators → increment pocketbase_count
3. If all counts are 0:
   a. Read pubspec.yaml
   b. Check dependencies section
   c. Return backend based on dependency presence
4. Return backend with highest count
5. If tie, check most recent file modification
6. Final fallback: return 'firebase'
```

## Implementation Example

When generating a new service, the detector should:

1. Run detection to get backend type: `backend = detectBackend()`
2. Generate service with appropriate imports and patterns
3. Include backend-specific initialization if needed

## Backend-Specific Service Patterns

### Firebase Service Pattern

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserService {
  UserService();

  final firestore = FirebaseFirestore.instance;

  Future<User> getUser(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw UserException('User not found');
      }
      return User.fromJson(doc.data()!);
    } catch (e) {
      throw UserException('Failed to get user: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final snapshot = await firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      throw UserException('Failed to get users: $e');
    }
  }

  Future<void> createUser(User user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw UserException('Failed to create user: $e');
    }
  }
}
```

### Supabase Service Pattern

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserService {
  UserService();

  final supabase = Supabase.instance.client;

  Future<User> getUser(String userId) async {
    try {
      final data = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return User.fromJson(data);
    } catch (e) {
      throw UserException('Failed to get user: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final data = await supabase.from('users').select();
      return (data as List).map((item) => User.fromJson(item)).toList();
    } catch (e) {
      throw UserException('Failed to get users: $e');
    }
  }

  Future<void> createUser(User user) async {
    try {
      await supabase.from('users').insert(user.toJson());
    } catch (e) {
      throw UserException('Failed to create user: $e');
    }
  }
}
```

### Pocketbase Service Pattern

```dart
import 'package:pocketbase/pocketbase.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserService {
  UserService();

  final pb = PocketBase('https://your-pocketbase-url.com');

  Future<User> getUser(String userId) async {
    try {
      final record = await pb.collection('users').getOne(userId);
      return User.fromJson(record.toJson());
    } catch (e) {
      throw UserException('Failed to get user: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final records = await pb.collection('users').getFullList();
      return records.map((record) => User.fromJson(record.toJson())).toList();
    } catch (e) {
      throw UserException('Failed to get users: $e');
    }
  }

  Future<void> createUser(User user) async {
    try {
      await pb.collection('users').create(body: user.toJson());
    } catch (e) {
      throw UserException('Failed to create user: $e');
    }
  }
}
```

## Usage in Agents

When creating a service in any agent (feature-creator, service-creator):

1. **Detect Backend First**:
   ```
   Use Glob to find: lib/features/*/services/*.dart
   Read 2-3 service files
   Analyze imports and patterns
   Determine active backend
   ```

2. **Generate Appropriate Code**:
   ```
   If backend == 'firebase':
     Use Firebase patterns
     Import firebase packages
   Else if backend == 'supabase':
     Use Supabase patterns
     Import supabase packages
   Else if backend == 'pocketbase':
     Use Pocketbase patterns
     Import pocketbase package
   ```

3. **Consistent Patterns**:
   - Use same error handling approach
   - Use same collection/table naming
   - Use same data transformation methods

## Validation

After detecting backend, validate:

1. **Dependencies exist**: Check that detected backend is in pubspec.yaml
2. **Initialization present**: Verify backend is initialized in main.dart
3. **Config files exist**: Check for Firebase config, Supabase keys, etc.

If validation fails, warn the user and ask for confirmation.

## Edge Cases

### Multi-tenant Applications
Some apps might use multiple backends (rare):
- Firebase for auth
- Supabase for data
- Approach: Detect based on data services, not auth

### Backend Migration
If project is mid-migration:
- Both backends present
- Approach: Ask user which to use for new services
- Or detect based on most recent services

### No Backend
Some features might be local-only:
- No network calls
- Approach: Skip backend detection
- Generate service without backend-specific code

## Future Enhancements

1. **GraphQL Detection**: Add support for GraphQL backends
2. **REST API Detection**: Generic REST API pattern detection
3. **Custom Backend**: Allow user to specify custom backend pattern
4. **Migration Helper**: Tool to migrate services between backends
