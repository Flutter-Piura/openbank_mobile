import 'package:flutter/material.dart';
import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/domain/customer.dart';
import 'package:openbank_mobile/shared/domain/money.dart';
import 'package:openbank_mobile/shared/presentation/money_format.dart';

enum MoreAction { refresh, signOut }

class MorePage extends StatelessWidget {
  const MorePage({required this.customer, required this.accounts, super.key});

  final Customer customer;
  final List<Account> accounts;

  String get _initials {
    final parts = customer.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2);
    return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
  }

  Money get _totalBalance {
    final currency = accounts.isEmpty
        ? 'PEN'
        : accounts.first.availableBalance.currency;
    return Money(
      minorUnits: accounts.fold(
        0,
        (total, account) => total + account.availableBalance.minorUnits,
      ),
      currency: currency,
    );
  }

  Future<void> _showAbout(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de OpenBank'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OpenBank 0.2.0',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text(
              'Proyecto educativo open source de Flutter Piura para aprender '
              'arquitectura multirepo y Clean Architecture.',
            ),
            SizedBox(height: 12),
            Text(
              'Esta aplicación no procesa dinero ni datos bancarios reales.',
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const ValueKey('close-about'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que ingresar nuevamente para volver a la demostración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const ValueKey('confirm-sign-out'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(MoreAction.signOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountLabel = accounts.length == 1
        ? '1 cuenta ficticia'
        : '${accounts.length} cuentas ficticias';
    return Scaffold(
      appBar: AppBar(title: const Text('Más')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        _initials,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.displayName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(customer.email),
                          const SizedBox(height: 6),
                          const Text(
                            'Perfil de demostración',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Resumen',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined),
                    const SizedBox(width: 14),
                    Expanded(child: Text(accountLabel)),
                    Text(
                      formatMoney(_totalBalance),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opciones',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    key: const ValueKey('more-refresh'),
                    leading: const Icon(Icons.refresh_rounded),
                    title: const Text('Actualizar información'),
                    subtitle: const Text('Volver a consultar perfil y cuentas'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(MoreAction.refresh),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: const Text('Volver a mis cuentas'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    key: const ValueKey('more-about'),
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Acerca de OpenBank'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.school_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tus cuentas, saldos y movimientos son ficticios. '
                        'Puedes explorar la demo con seguridad.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const ValueKey('more-sign-out'),
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
