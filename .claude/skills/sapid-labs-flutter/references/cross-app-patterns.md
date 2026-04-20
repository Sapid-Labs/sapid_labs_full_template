# Cross-App Patterns

Patterns discovered across Sapid Labs apps that go beyond the template baseline. These are reusable solutions to problems multiple apps have solved.

## Table of Contents
- Real-Time Chat (CubCampus)
- Media Recording & Playback (Vault Messages)
- Push Notifications
- Maps & Geolocation (CubCampus)
- Image Handling
- In-App Purchases

## Real-Time Chat (CubCampus)

CubCampus implements real-time messaging between parents and sitters. The pattern:

1. **Message model** with sender/receiver IDs, content, timestamp, read status
2. **Chat service** as `@singleton` with Firestore snapshot listeners
3. **Signal-based state** — `messageList` signal updates reactively as Firestore emits snapshots
4. **Optimistic UI** — add message to local list immediately, write to Firestore async

```dart
// Simplified chat pattern
final messageList = listSignal<Message>([]);

@singleton
class ChatService {
  StreamSubscription? _sub;

  void listenToChat(String chatId) {
    _sub?.cancel();
    _sub = firestore
        .collection('chats/$chatId/messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .listen((snap) {
      messageList.value = snap.docs
          .map((d) => Message.fromJson({...d.data(), 'id': d.id}))
          .toList();
    });
  }

  Future<void> sendMessage(String chatId, Message msg) async {
    // Optimistic update
    messageList.value = [msg, ...messageList.value];
    // Persist
    await firestore.collection('chats/$chatId/messages').add(msg.toJson());
  }
}
```

## Media Recording & Playback (Vault Messages)

Vault Messages handles audio recording and playback, plus video and image attachments.

### Audio Recording
Uses the `record` package:
```dart
import 'package:record/record.dart';

final recorder = AudioRecorder();

// Start recording
await recorder.start(const RecordConfig(), path: tempPath);

// Stop and get file
final path = await recorder.stop();
```

### Audio Playback
Uses `audioplayers`:
```dart
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
await player.play(UrlSource(audioUrl));
await player.pause();
await player.stop();
```

### File Upload to Firebase Storage
```dart
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadFile(File file, String path) async {
  final ref = FirebaseStorage.instance.ref(path);
  await ref.putFile(file);
  return await ref.getDownloadURL();
}
```

### Image Compression
Both CubCampus and Vault Messages compress images before upload:
```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File?> compressImage(File file) async {
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    '${file.parent.path}/compressed_${file.uri.pathSegments.last}',
    quality: 70,
  );
  return result != null ? File(result.path) : null;
}
```

## Push Notifications

Two patterns are used across apps:

### Firebase Cloud Messaging (CubCampus, Vault Messages)
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Request permission
await FirebaseMessaging.instance.requestPermission();

// Get token for server-side targeting
final token = await FirebaseMessaging.instance.getToken();

// Foreground messages
FirebaseMessaging.onMessage.listen((message) {
  // Show local notification
  flutterLocalNotificationsPlugin.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
  );
});

// Background/terminated messages
FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
```

### Token Storage Pattern
Store FCM tokens per user in Firestore so the server can target notifications:
```dart
Future<void> saveToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null && authUserId.value != null) {
    await firestore.collection('users').doc(authUserId.value).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }
}
```

## Maps & Geolocation (CubCampus)

CubCampus uses Google Maps for campus location features:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// Check and request location permission
final permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  await Geolocator.requestPermission();
}

// Get current position
final position = await Geolocator.getCurrentPosition();

// Google Maps widget
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(position.latitude, position.longitude),
    zoom: 15,
  ),
  markers: markers,
  onMapCreated: (controller) => _mapController = controller,
)
```

## Image Handling

Common pattern across CubCampus, Vault Messages, and other apps:

### Picking Images
```dart
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

// From camera
final photo = await picker.pickImage(source: ImageSource.camera);

// From gallery
final image = await picker.pickImage(source: ImageSource.gallery);
```

### Cached Network Images
```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

## In-App Purchases

### RevenueCat (Template default)
The template includes RevenueCat integration via `purchases_flutter`.

### Native IAP (Vault Messages)
Vault Messages uses `in_app_purchase` directly:
```dart
import 'package:in_app_purchase/in_app_purchase.dart';

// Listen to purchase stream
InAppPurchase.instance.purchaseStream.listen((purchases) {
  for (final purchase in purchases) {
    if (purchase.status == PurchaseStatus.purchased) {
      // Verify and deliver
    }
  }
});

// Query products
final response = await InAppPurchase.instance.queryProductDetails({'premium'});
```
