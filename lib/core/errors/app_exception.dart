class AppException implements Exception {
  const AppException({
    required this.message,
    this.code = 'unexpected_error',
    this.statusCode,
    this.correlationId,
  });

  final String message;
  final String code;
  final int? statusCode;
  final String? correlationId;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}
