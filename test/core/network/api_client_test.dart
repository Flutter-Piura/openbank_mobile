import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbank_mobile/core/errors/app_exception.dart';
import 'package:openbank_mobile/core/network/api_client.dart';

void main() {
  test('sends bearer token and decodes an object response', () async {
    late http.Request captured;
    final httpClient = MockClient((request) async {
      captured = request;
      return http.Response(jsonEncode({'status': 'ok'}), 200);
    });
    final client = ApiClient(
      baseUri: Uri.parse('https://api.openbank.test'),
      httpClient: httpClient,
    )..setAccessToken('demo-token');

    final response = await client.getObject('/health');

    expect(response['status'], 'ok');
    expect(captured.url.toString(), 'https://api.openbank.test/health');
    expect(captured.headers['Authorization'], 'Bearer demo-token');
  });

  test('maps problem details into an AppException', () async {
    final httpClient = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'code': 'insufficient_funds',
          'message': 'Saldo insuficiente.',
          'correlationId': 'test-correlation-id',
        }),
        422,
        headers: {'content-type': 'application/problem+json'},
      ),
    );
    final client = ApiClient(
      baseUri: Uri.parse('https://api.openbank.test'),
      httpClient: httpClient,
    );

    await expectLater(
      client.postObject('/v1/transfers', body: const {}),
      throwsA(
        isA<AppException>()
            .having((error) => error.code, 'code', 'insufficient_funds')
            .having((error) => error.statusCode, 'statusCode', 422)
            .having(
              (error) => error.correlationId,
              'correlationId',
              'test-correlation-id',
            ),
      ),
    );
  });
}
