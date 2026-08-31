import 'package:flutter/material.dart';
import 'package:openbank_mobile/core/errors/app_exception.dart';
import 'package:openbank_mobile/features/accounts/application/load_dashboard.dart';
import 'package:openbank_mobile/features/accounts/application/load_transactions.dart';
import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/accounts/presentation/account_detail_page.dart';
import 'package:openbank_mobile/features/authentication/application/sign_out.dart';
import 'package:openbank_mobile/features/transfers/application/create_transfer.dart';
import 'package:openbank_mobile/features/transfers/presentation/transfer_page.dart';
import 'package:openbank_mobile/shared/domain/money.dart';
import 'package:openbank_mobile/shared/presentation/money_format.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.loadDashboard,
    required this.loadTransactions,
    required this.createTransfer,
    required this.signOut,
    required this.onSignedOut,
    super.key,
  });

  final LoadDashboard loadDashboard;
  final LoadTransactions loadTransactions;
  final CreateTransfer createTransfer;
  final SignOut signOut;
  final VoidCallback onSignedOut;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardSnapshot? _snapshot;
  String? _error;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _snapshot = null;
      _error = null;
    });
    try {
      final snapshot = await widget.loadDashboard();
      if (mounted) setState(() => _snapshot = snapshot);
    } on AppException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        widget.onSignedOut();
      } else {
        setState(() => _error = error.message);
      }
    } on Object {
      if (mounted) setState(() => _error = 'No pudimos cargar tu información.');
    }
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await widget.signOut();
    } on Object {
      // El repositorio limpia siempre la sesión local incluso si la API falla.
    } finally {
      if (mounted) widget.onSignedOut();
    }
  }

  Future<void> _openTransfer(List<Account> accounts) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransferPage(
          accounts: accounts,
          createTransfer: widget.createTransfer,
        ),
      ),
    );
    if (created ?? false) await _load();
  }

  void _openAccount(Account account) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AccountDetailPage(
          account: account,
          loadTransactions: widget.loadTransactions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_rounded),
            SizedBox(width: 10),
            Text('OpenBank'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _signingOut ? null : _signOut,
            icon: _signingOut
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_error case final error?) {
      return _FullPageError(message: error, onRetry: _load);
    }
    final snapshot = _snapshot;
    if (snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final accounts = snapshot.accounts;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Hola, ${snapshot.customer.displayName.split(' ').first}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Este es el resumen de tus cuentas ficticias.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _TotalBalanceCard(accounts: accounts),
          const SizedBox(height: 16),
          _QuickActions(
            canTransfer: accounts.length > 1,
            onTransfer: () => _openTransfer(accounts),
          ),
          const SizedBox(height: 28),
          Text(
            'Mis cuentas',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (accounts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No tienes cuentas disponibles.'),
              ),
            )
          else
            ...accounts.map(
              (account) => _AccountCard(
                account: account,
                onTap: () => _openAccount(account),
              ),
            ),
          const SizedBox(height: 16),
          const _EducationNotice(),
        ],
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final total = accounts.fold<int>(
      0,
      (sum, item) => sum + item.availableBalance.minorUnits,
    );
    final currency = accounts.isEmpty
        ? 'PEN'
        : accounts.first.availableBalance.currency;
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, const Color(0xFF334E68)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo total disponible',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(Money(minorUnits: total, currency: currency)),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Datos de demostración',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.canTransfer, required this.onTransfer});

  final bool canTransfer;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: canTransfer ? onTransfer : null,
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const Text('Transferir'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Más funciones llegarán en la siguiente fase.'),
              ),
            ),
            icon: const Icon(Icons.more_horiz_rounded),
            label: const Text('Más'),
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap});

  final Account account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                child: const Icon(Icons.account_balance_wallet_outlined),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.alias,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      account.maskedNumber,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(account.availableBalance),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EducationNotice extends StatelessWidget {
  const _EducationNotice();

  @override
  Widget build(BuildContext context) {
    return Card(
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
                'OpenBank es un proyecto educativo open source. No procesa fondos reales.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullPageError extends StatelessWidget {
  const _FullPageError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
