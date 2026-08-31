import 'package:openbank_mobile/shared/domain/money.dart';

class BankTransaction {
  const BankTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.description,
    required this.amount,
    required this.occurredAt,
    this.transferId,
  });

  final String id;
  final String accountId;
  final String? transferId;
  final String type;
  final String description;
  final Money amount;
  final DateTime occurredAt;
}
