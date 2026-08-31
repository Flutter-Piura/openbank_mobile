import 'package:openbank_mobile/core/network/api_client.dart';
import 'package:openbank_mobile/features/authentication/domain/auth_repository.dart';
import 'package:openbank_mobile/features/authentication/domain/auth_session.dart';
import 'package:openbank_mobile/features/authentication/infrastructure/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._client);

  final AuthRemoteDataSource _remote;
  final ApiClient _client;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remote.login(email: email, password: password);
    _client.setAccessToken(session.accessToken);
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } finally {
      _client.setAccessToken(null);
    }
  }
}
