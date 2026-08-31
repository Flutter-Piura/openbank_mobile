import 'package:openbank_mobile/core/network/api_client.dart';
import 'package:openbank_mobile/features/authentication/domain/auth_session.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _client.postObject(
      '/v1/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
    );
  }

  Future<void> logout() => _client.postEmpty('/v1/auth/logout');
}
