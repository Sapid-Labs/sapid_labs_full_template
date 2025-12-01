import 'dart:async';
import 'package:http/http.dart' as http;

/// Custom HTTP client that adds default headers to every request
class CustomHttpClient extends http.BaseClient {
  final http.Client _inner;
  final Map<String, String> _defaultHeaders;

  CustomHttpClient({
    http.Client? client,
    Map<String, String>? defaultHeaders,
  })  : _inner = client ?? http.Client(),
        _defaultHeaders = defaultHeaders ?? {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add default headers to every request
    _defaultHeaders.forEach((key, value) {
      if (!request.headers.containsKey(key)) {
        request.headers[key] = value;
      }
    });

    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }

  /// Update default headers
  void updateDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders.addAll(headers);
  }

  /// Remove a default header
  void removeDefaultHeader(String key) {
    _defaultHeaders.remove(key);
  }

  /// Get current default headers
  Map<String, String> get defaultHeaders => Map.unmodifiable(_defaultHeaders);
}
