import 'package:openbank_mobile/features/authentication/domain/auth_repository.dart';
import 'package:openbank_mobile/features/authentication/domain/auth_session.dart';

class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
