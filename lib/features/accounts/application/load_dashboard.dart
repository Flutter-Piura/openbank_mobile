import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/domain/account_repository.dart';
import 'package:openbank_mobile/features/accounts/domain/customer.dart';

class DashboardSnapshot {
  const DashboardSnapshot({required this.customer, required this.accounts});

  final Customer customer;
  final List<Account> accounts;
}

class LoadDashboard {
  const LoadDashboard(this._repository);

  final AccountRepository _repository;

  Future<DashboardSnapshot> call() async {
    final results = await Future.wait<Object>([
      _repository.getCurrentCustomer(),
      _repository.listAccounts(),
    ]);
    return DashboardSnapshot(
      customer: results[0] as Customer,
      accounts: results[1] as List<Account>,
    );
  }
}
