import 'package:openbank_mobile/shared/domain/money.dart';

class Transfer {
  const Transfer({
    required this.id,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.reference,
    this.rejectionCode,
    this.completedAt,
  });

  final String id;
  final String sourceAccountId;
  final String destinationAccountId;
  final Money amount;
  final String? reference;
  final String status;
  final String? rejectionCode;
  final DateTime createdAt;
  final DateTime? completedAt;
}
