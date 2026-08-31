import 'package:openbank_mobile/features/accounts/domain/account_repository.dart';
import 'package:openbank_mobile/features/accounts/domain/bank_transaction.dart';

class LoadTransactions {
  const LoadTransactions(this._repository);

  final AccountRepository _repository;

  Future<List<BankTransaction>> call(String accountId) {
    return _repository.listTransactions(accountId);
  }
}
