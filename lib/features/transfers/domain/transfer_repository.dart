import 'package:openbank_mobile/features/transfers/domain/transfer.dart';
import 'package:openbank_mobile/shared/domain/money.dart';

abstract interface class TransferRepository {
  Future<Transfer> createTransfer({
    required String sourceAccountId,
    required String destinationAccountId,
    required Money amount,
    required String idempotencyKey,
    String? reference,
  });
}
