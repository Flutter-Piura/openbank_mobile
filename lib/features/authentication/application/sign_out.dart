import 'package:openbank_mobile/features/authentication/domain/auth_repository.dart';

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
