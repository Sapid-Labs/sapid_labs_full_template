// STACK_AMPLITUDE — this entire file is Amplitude-specific
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Replace with your Amplitude API key when using this file
final Amplitude amplitude = Amplitude(Configuration(
  apiKey: const String.fromEnvironment("AMPLITUDE_API_KEY"),
));

/// Navigation observer that automatically tracks page navigation events using Amplitude.
/// This observer will track route changes, providing analytics on user navigation patterns.
class AmplitudeNavigationObserver extends AutoRouterObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _trackNavigation('page viewed', route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackNavigation('page viewed', previousRoute, route);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackNavigation('page viewed', newRoute, oldRoute);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _trackNavigation('page viewed', previousRoute, route);
    }
  }

  /// Track navigation events with route information
  void _trackNavigation(String eventName, Route route, Route? previousRoute) {
    try {
      final routeName = _getRouteName(route);
      final previousRouteName =
          previousRoute != null ? _getRouteName(previousRoute) : null;

      if (routeName.isNotEmpty) {
        // Create event properties with navigation context
        final eventProperties = <String, dynamic>{
          'page_name': routeName,
          'page_path': _getRoutePath(route),
        };

        // Add previous route context if available
        if (previousRouteName != null && previousRouteName.isNotEmpty) {
          eventProperties['previous_page'] = previousRouteName;
          eventProperties['previous_page_path'] = _getRoutePath(previousRoute!);
        }

        // Add route arguments if available
        final routeArgs = _getRouteArguments(route);
        if (routeArgs.isNotEmpty) {
          eventProperties.addAll(routeArgs);
        }

        // Track the navigation event
        amplitude.track(BaseEvent(eventName, eventProperties: eventProperties));

        if (kDebugMode) {
          print('Amplitude Navigation: $eventName - $routeName');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking navigation: $e');
      }
    }
  }

  /// Extract the route name from a Route object
  String _getRouteName(Route route) {
    if (route.settings.name != null) {
      // Remove the 'Route' suffix and convert to readable format
      return route.settings.name!
          .replaceAll('Route', '')
          .trim()
          .toLowerCase();
    }
    return '';
  }

  /// Extract the route path from a Route object
  String _getRoutePath(Route route) {
    if (route.settings.name != null) {
      return route.settings.name!;
    }
    return '';
  }

  /// Extract relevant route arguments for analytics
  Map<String, dynamic> _getRouteArguments(Route route) {
    final args = <String, dynamic>{};

    if (route.settings.arguments != null) {
      final arguments = route.settings.arguments;

      // Handle different types of route arguments based on the Auto Route patterns
      if (arguments is Map) {
        // Extract common useful properties for analytics
        for (final entry in arguments.entries) {
          final key = entry.key.toString();
          final value = entry.value;

          // Include specific useful properties for analytics
          if (_isAnalyticsRelevantProperty(key, value)) {
            args[_sanitizePropertyKey(key)] = _sanitizePropertyValue(value);
          }
        }
      }
    }

    return args;
  }

  /// Determine if a property is relevant for analytics tracking
  bool _isAnalyticsRelevantProperty(String key, dynamic value) {
    // Include IDs, search terms, and other relevant navigation context
    final relevantKeys = [
      'id',
      'bookId',
      'term',
      'url',
      'source',
      'email',
    ];

    // Include if key matches relevant patterns and value is not null
    return relevantKeys.any(
            (pattern) => key.toLowerCase().contains(pattern.toLowerCase())) &&
        value != null &&
        value.toString().isNotEmpty;
  }

  /// Sanitize property keys for Amplitude
  String _sanitizePropertyKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
  }

  /// Sanitize property values for Amplitude
  dynamic _sanitizePropertyValue(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString();

    // Truncate long values to prevent analytics bloat
    if (stringValue.length > 100) {
      return stringValue.substring(0, 100) + '...';
    }

    return stringValue;
  }
}
