---
mode: "agent"
tools: ["codebase", "editFiles", "search"]
description: "Track user interactions and events in the app using Amplitude"
---

Your goal is to add a Amplitude event tracking to the requested part of the app. Follow these steps:

1. Import the [amplitude](../../lib/main.dart) object from the main app file where the Amplitude instance is initialized.

2. Track the requested action(s) using the following pattern:

```dart
amplitude.track(BaseEvent('verb element'));
```

For user interactions, replace `verb` with the action being performed (e.g., 'press', 'click', 'swipe') and `element` with the specific UI element or action (e.g., 'get premium', 'view recipe', 'search recipes').

```dart
amplitude.track(BaseEvent('press get premium'));
```

For events that are not directly user interactions, use a more descriptive event name that reflects the action or state change (e.g., 'recipe viewed', 'search performed').

If there are additional properties to track, you can include them in the `eventProperties` parameter of the `BaseEvent` constructor:

```dart
amplitude.track(BaseEvent('verb element', eventProperties: {
  'property_name': 'property_value',
}));
```
