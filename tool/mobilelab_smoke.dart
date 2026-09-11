import 'package:openbank_mobile/app/app_dependencies.dart';
import 'package:openbank_mobile/core/identifiers/uuid_v4.dart';
import 'package:openbank_mobile/shared/domain/money.dart';

Future<void> main() async {
  final dependencies = AppDependencies.standard();
  try {
    await dependencies.signIn(
      email: 'demo@openbank.local',
      password: 'OpenBankDemo!2026',
    );

    final dashboard = await dependencies.loadDashboard();
    _require(dashboard.customer.email == 'demo@openbank.local', 'perfil demo');
    _require(dashboard.accounts.length >= 2, 'al menos dos cuentas');

    final source = dashboard.accounts[0];
    final destination = dashboard.accounts[1];
    final transactions = await dependencies.loadTransactions(source.id);
    _require(transactions.isNotEmpty, 'movimientos de la cuenta principal');

    final transfer = await dependencies.createTransfer(
      sourceAccountId: source.id,
      destinationAccountId: destination.id,
      amount: Money(
        minorUnits: 1000,
        currency: source.availableBalance.currency,
      ),
      reference: 'Smoke test OpenBank',
      idempotencyKey: generateUuidV4(),
    );
    _require(transfer.status == 'completed', 'transferencia completada');

    await dependencies.signOut();
    // ignore: avoid_print
    print(
      'OpenBank smoke OK: ${dashboard.accounts.length} cuentas, '
      '${transactions.length} movimientos y transferencia ${transfer.id}.',
    );
  } finally {
    dependencies.dispose();
  }
}

void _require(bool condition, String expectation) {
  if (!condition) {
    throw StateError('Falló el smoke test: se esperaba $expectation.');
  }
}
