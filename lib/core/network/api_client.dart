import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openbank_mobile/core/errors/app_exception.dart';

class ApiClient {
  ApiClient({
    required this.baseUri,
    required this.httpClient,
    this.timeout = const Duration(seconds: 12),
  });

  final Uri baseUri;
  final http.Client httpClient;
  final Duration timeout;
  String? _accessToken;

  void setAccessToken(String? token) => _accessToken = token;

  Future<Map<String, Object?>> getObject(String path) async {
    final body = await _send(method: 'GET', path: path);
    return _expectObject(body);
  }

  Future<Map<String, Object?>> postObject(
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _send(
      method: 'POST',
      path: path,
      body: body,
      headers: headers,
    );
    return _expectObject(response);
  }

  Future<void> postEmpty(String path, {Map<String, Object?>? body}) async {
    await _send(method: 'POST', path: path, body: body);
  }

  Future<Object?> _send({
    required String method,
    required String path,
    Map<String, Object?>? body,
    Map<String, String>? headers,
  }) async {
    final request = http.Request(method, baseUri.resolve(path));
    request.headers.addAll({
      'Accept': 'application/json, application/problem+json',
      if (_accessToken case final token?) 'Authorization': 'Bearer $token',
      ...?headers,
    });
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    try {
      final streamed = await httpClient.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      final decoded = _decode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _problem(response.statusCode, decoded);
      }
      return decoded;
    } on TimeoutException {
      throw const AppException(
        code: 'network_timeout',
        message: 'La conexión tardó demasiado. Intenta nuevamente.',
      );
    } on AppException {
      rethrow;
    } on Object {
      throw const AppException(
        code: 'network_error',
        message: 'No se pudo conectar con OpenBank. Verifica el sandbox local.',
      );
    }
  }

  Object? _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw AppException(
        code: 'invalid_response',
        statusCode: response.statusCode,
        message: 'OpenBank devolvió una respuesta que no se pudo interpretar.',
      );
    }
  }

  AppException _problem(int statusCode, Object? body) {
    if (body case final Map<String, Object?> problem) {
      return AppException(
        statusCode: statusCode,
        code: problem['code'] as String? ?? 'api_error',
        message: problem['message'] as String? ?? _fallbackMessage(statusCode),
        correlationId: problem['correlationId'] as String?,
      );
    }
    return AppException(
      statusCode: statusCode,
      code: 'api_error',
      message: _fallbackMessage(statusCode),
    );
  }

  String _fallbackMessage(int statusCode) => switch (statusCode) {
    401 => 'Tu sesión expiró. Ingresa nuevamente.',
    404 => 'No se encontró el recurso solicitado.',
    422 => 'La operación no cumple las reglas de OpenBank.',
    429 => 'Hay demasiadas solicitudes. Intenta nuevamente en unos segundos.',
    _ => 'No pudimos completar la operación.',
  };

  Map<String, Object?> _expectObject(Object? body) {
    if (body case final Map<String, Object?> object) return object;
    throw const AppException(
      code: 'invalid_response',
      message: 'OpenBank devolvió una respuesta inesperada.',
    );
  }
}
