import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/domain/account_repository.dart';
import 'package:openbank_mobile/features/accounts/domain/bank_transaction.dart';
import 'package:openbank_mobile/features/accounts/domain/customer.dart';
import 'package:openbank_mobile/features/accounts/infrastructure/banking_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  const AccountRepositoryImpl(this._remote);

  final BankingRemoteDataSource _remote;

  @override
  Future<Customer> getCurrentCustomer() => _remote.getCurrentCustomer();

  @override
  Future<List<Account>> listAccounts() => _remote.listAccounts();

  @override
  Future<List<BankTransaction>> listTransactions(String accountId) {
    return _remote.listTransactions(accountId);
  }
}
