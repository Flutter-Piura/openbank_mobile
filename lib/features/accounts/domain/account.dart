import 'package:openbank_mobile/shared/domain/money.dart';

class Account {
  const Account({
    required this.id,
    required this.alias,
    required this.maskedNumber,
    required this.status,
    required this.availableBalance,
    this.createdAt,
  });

  final String id;
  final String alias;
  final String maskedNumber;
  final String status;
  final Money availableBalance;
  final DateTime? createdAt;
}
