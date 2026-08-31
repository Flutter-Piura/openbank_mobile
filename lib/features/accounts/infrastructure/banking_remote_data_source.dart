import 'package:openbank_mobile/core/errors/app_exception.dart';
import 'package:openbank_mobile/core/network/api_client.dart';
import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/domain/bank_transaction.dart';
import 'package:openbank_mobile/features/accounts/domain/customer.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer.dart';
import 'package:openbank_mobile/shared/domain/money.dart';

class BankingRemoteDataSource {
  const BankingRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Customer> getCurrentCustomer() async {
    final json = await _client.getObject('/v1/me');
    return Customer(
      id: _string(json, 'id'),
      displayName: _string(json, 'displayName'),
      email: _string(json, 'email'),
    );
  }

  Future<List<Account>> listAccounts() async {
    final json = await _client.getObject('/v1/accounts');
    return _objectList(json, 'items').map(_account).toList(growable: false);
  }

  Future<List<BankTransaction>> listTransactions(String accountId) async {
    final json = await _client.getObject(
      '/v1/accounts/${Uri.encodeComponent(accountId)}/transactions',
    );
    return _objectList(json, 'items').map(_transaction).toList(growable: false);
  }

  Future<Transfer> createTransfer({
    required String sourceAccountId,
    required String destinationAccountId,
    required Money amount,
    required String idempotencyKey,
    String? reference,
  }) async {
    final json = await _client.postObject(
      '/v1/transfers',
      headers: {'Idempotency-Key': idempotencyKey},
      body: {
        'sourceAccountId': sourceAccountId,
        'destinationAccountId': destinationAccountId,
        'amount': _moneyJson(amount),
        if (reference != null && reference.isNotEmpty) 'reference': reference,
      },
    );
    return _transfer(json);
  }

  Account _account(Map<String, Object?> json) => Account(
    id: _string(json, 'id'),
    alias: _string(json, 'alias'),
    maskedNumber: _string(json, 'maskedNumber'),
    status: _string(json, 'status'),
    availableBalance: _money(_object(json, 'availableBalance')),
    createdAt: _optionalDate(json, 'createdAt'),
  );

  BankTransaction _transaction(Map<String, Object?> json) => BankTransaction(
    id: _string(json, 'id'),
    accountId: _string(json, 'accountId'),
    transferId: json['transferId'] as String?,
    type: _string(json, 'type'),
    description: _string(json, 'description'),
    amount: _money(_object(json, 'amount')),
    occurredAt: _date(json, 'occurredAt'),
  );

  Transfer _transfer(Map<String, Object?> json) => Transfer(
    id: _string(json, 'id'),
    sourceAccountId: _string(json, 'sourceAccountId'),
    destinationAccountId: _string(json, 'destinationAccountId'),
    amount: _money(_object(json, 'amount')),
    reference: json['reference'] as String?,
    status: _string(json, 'status'),
    rejectionCode: json['rejectionCode'] as String?,
    createdAt: _date(json, 'createdAt'),
    completedAt: _optionalDate(json, 'completedAt'),
  );

  Money _money(Map<String, Object?> json) => Money(
    minorUnits: _integer(json, 'minorUnits'),
    currency: _string(json, 'currency'),
  );

  Map<String, Object?> _moneyJson(Money money) => {
    'minorUnits': money.minorUnits,
    'currency': money.currency,
  };

  List<Map<String, Object?>> _objectList(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List<Object?>) {
      throw _invalid(key);
    }
    return value
        .map((item) {
          if (item is Map<String, Object?>) return item;
          throw _invalid(key);
        })
        .toList(growable: false);
  }

  Map<String, Object?> _object(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is Map<String, Object?>) return value;
    throw _invalid(key);
  }

  String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw _invalid(key);
  }

  int _integer(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) return value;
    throw _invalid(key);
  }

  DateTime _date(Map<String, Object?> json, String key) {
    final parsed = DateTime.tryParse(_string(json, key));
    if (parsed != null) return parsed;
    throw _invalid(key);
  }

  DateTime? _optionalDate(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value) ?? (throw _invalid(key));
    }
    throw _invalid(key);
  }

  AppException _invalid(String field) => AppException(
    code: 'invalid_response',
    message: 'La respuesta de OpenBank no contiene un campo válido: $field.',
  );
}
