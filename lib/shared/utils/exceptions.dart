class AppException implements Exception {
  const AppException(this.message, {this.code, this.details});
  final String message;
  final String? details;
  final dynamic code;
  @override
  String toString() => message + (details != null ? '\n$details' : '');
}
