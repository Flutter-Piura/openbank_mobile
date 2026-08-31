import 'package:openbank_mobile/features/accounts/infrastructure/banking_remote_data_source.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer_repository.dart';
import 'package:openbank_mobile/shared/domain/money.dart';

class TransferRepositoryImpl implements TransferRepository {
  const TransferRepositoryImpl(this._remote);

  final BankingRemoteDataSource _remote;

  @override
  Future<Transfer> createTransfer({
    required String sourceAccountId,
    required String destinationAccountId,
    required Money amount,
    required String idempotencyKey,
    String? reference,
  }) {
    return _remote.createTransfer(
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      idempotencyKey: idempotencyKey,
      reference: reference,
    );
  }
}
