import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbank_mobile/app/app_dependencies.dart';
import 'package:openbank_mobile/features/accounts/application/load_dashboard.dart';
import 'package:openbank_mobile/features/accounts/application/load_transactions.dart';
import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/domain/account_repository.dart';
import 'package:openbank_mobile/features/accounts/domain/bank_transaction.dart';
import 'package:openbank_mobile/features/accounts/domain/customer.dart';
import 'package:openbank_mobile/features/authentication/application/sign_in.dart';
import 'package:openbank_mobile/features/authentication/application/sign_out.dart';
import 'package:openbank_mobile/features/authentication/domain/auth_repository.dart';
import 'package:openbank_mobile/features/authentication/domain/auth_session.dart';
import 'package:openbank_mobile/features/transfers/application/create_transfer.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer_repository.dart';
import 'package:openbank_mobile/main.dart';
import 'package:openbank_mobile/shared/domain/money.dart';
import 'package:openbank_mobile/shared/presentation/money_format.dart';

void main() {
  testWidgets('completes the demo banking journey', (tester) async {
    final dependencies = _testDependencies();
    await tester.pumpWidget(OpenBankApp(dependencies: dependencies));

    expect(find.text('OpenBank'), findsOneWidget);
    expect(find.text('Ingresar a la demo'), findsOneWidget);

    await tester.tap(find.text('Ingresar a la demo'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Cliente'), findsOneWidget);
    expect(find.text('Mis cuentas'), findsOneWidget);
    expect(find.text('Cuenta principal'), findsOneWidget);
    expect(
      find.text(formatMoney(_FakeAccountRepository.primary.availableBalance)),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('more-action')));
    await tester.pumpAndSettle();

    expect(find.text('Perfil de demostración'), findsOneWidget);
    expect(find.text('Cliente Demo'), findsOneWidget);
    expect(find.text('demo@openbank.local'), findsOneWidget);
    expect(find.text('2 cuentas ficticias'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('more-about')));
    await tester.pumpAndSettle();
    expect(find.text('OpenBank 0.2.0'), findsOneWidget);
    expect(
      find.textContaining('no procesa dinero ni datos bancarios reales'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('close-about')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('more-refresh')));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Cliente'), findsOneWidget);

    await tester.tap(find.text('Cuenta principal'));
    await tester.pumpAndSettle();

    expect(find.text('Últimos movimientos'), findsOneWidget);
    expect(find.text('Depósito de demostración'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transferir'));
    await tester.pumpAndSettle();

    expect(find.text('Nueva transferencia'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '10.00');
    await tester.tap(find.widgetWithText(FilledButton, 'Transferir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Transferencia completada'), findsOneWidget);
    expect(
      find.text(formatMoney(const Money(minorUnits: 1000, currency: 'PEN'))),
      findsOneWidget,
    );
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Cliente'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('more-action')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('more-sign-out')),
      300,
    );
    await tester.tap(find.byKey(const ValueKey('more-sign-out')));
    await tester.pumpAndSettle();
    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-sign-out')));
    await tester.pumpAndSettle();

    expect(find.text('Ingresar a la demo'), findsOneWidget);
  });
}

AppDependencies _testDependencies() {
  final auth = _FakeAuthRepository();
  final accounts = _FakeAccountRepository();
  final transfers = _FakeTransferRepository();
  return AppDependencies(
    signIn: SignIn(auth),
    signOut: SignOut(auth),
    loadDashboard: LoadDashboard(accounts),
    loadTransactions: LoadTransactions(accounts),
    createTransfer: CreateTransfer(transfers),
    dispose: () {},
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return const AuthSession(
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
      tokenType: 'Bearer',
      expiresInSeconds: 900,
    );
  }

  @override
  Future<void> logout() async {}
}

class _FakeAccountRepository implements AccountRepository {
  static const primary = Account(
    id: '1b27fb57-13d2-4931-861c-c903f7e44c5f',
    alias: 'Cuenta principal',
    maskedNumber: '****4821',
    status: 'active',
    availableBalance: Money(minorUnits: 125050, currency: 'PEN'),
  );
  static const savings = Account(
    id: '93ed95bf-37e0-4119-809f-23b30153017d',
    alias: 'Cuenta de ahorro',
    maskedNumber: '****9134',
    status: 'active',
    availableBalance: Money(minorUnits: 450000, currency: 'PEN'),
  );

  @override
  Future<Customer> getCurrentCustomer() async => const Customer(
    id: '4a004784-e2ba-4892-986d-ce8cc3761c7e',
    displayName: 'Cliente Demo',
    email: 'demo@openbank.local',
  );

  @override
  Future<List<Account>> listAccounts() async => [primary, savings];

  @override
  Future<List<BankTransaction>> listTransactions(String accountId) async => [
    BankTransaction(
      id: '56fb078a-7963-4146-8a94-2347cc1a536e',
      accountId: accountId,
      type: 'deposit',
      description: 'Depósito de demostración',
      amount: const Money(minorUnits: 50000, currency: 'PEN'),
      occurredAt: DateTime.utc(2026, 8, 28, 15),
    ),
  ];
}

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<Transfer> createTransfer({
    required String sourceAccountId,
    required String destinationAccountId,
    required Money amount,
    required String idempotencyKey,
    String? reference,
  }) async {
    return Transfer(
      id: 'a88ee2f2-27b8-43a0-b6c4-3d846e724983',
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      reference: reference,
      status: 'completed',
      createdAt: DateTime.utc(2026, 8, 30, 20, 15),
      completedAt: DateTime.utc(2026, 8, 30, 20, 15, 1),
    );
  }
}
