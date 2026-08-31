import 'package:openbank_mobile/features/authentication/domain/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<void> logout();
}
