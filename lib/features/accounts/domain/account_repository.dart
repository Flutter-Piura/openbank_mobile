import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/domain/bank_transaction.dart';
import 'package:openbank_mobile/features/accounts/domain/customer.dart';

abstract interface class AccountRepository {
  Future<Customer> getCurrentCustomer();

  Future<List<Account>> listAccounts();

  Future<List<BankTransaction>> listTransactions(String accountId);
}
