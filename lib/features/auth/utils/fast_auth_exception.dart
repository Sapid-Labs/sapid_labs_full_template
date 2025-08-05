class FastAuthException implements Exception {
  final String message;
  final String? error;

  FastAuthException(
    this.message, {
    this.error,
  });
}
