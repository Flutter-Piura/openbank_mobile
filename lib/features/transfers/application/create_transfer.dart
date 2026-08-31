import 'package:openbank_mobile/features/transfers/domain/transfer.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer_repository.dart';
import 'package:openbank_mobile/shared/domain/money.dart';

class CreateTransfer {
  const CreateTransfer(this._repository);

  final TransferRepository _repository;

  Future<Transfer> call({
    required String sourceAccountId,
    required String destinationAccountId,
    required Money amount,
    required String idempotencyKey,
    String? reference,
  }) {
    if (sourceAccountId == destinationAccountId) {
      throw const FormatException('Selecciona dos cuentas diferentes.');
    }
    return _repository.createTransfer(
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      idempotencyKey: idempotencyKey,
      reference: reference,
    );
  }
}
