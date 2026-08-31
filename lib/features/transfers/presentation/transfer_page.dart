import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openbank_mobile/core/errors/app_exception.dart';
import 'package:openbank_mobile/features/accounts/domain/account.dart';
import 'package:openbank_mobile/features/transfers/application/create_transfer.dart';
import 'package:openbank_mobile/features/transfers/domain/transfer.dart';
import 'package:openbank_mobile/shared/domain/money.dart';
import 'package:openbank_mobile/shared/presentation/money_format.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({
    required this.accounts,
    required this.createTransfer,
    super.key,
  });

  final List<Account> accounts;
  final CreateTransfer createTransfer;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  late String _sourceId;
  late String _destinationId;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sourceId = widget.accounts.first.id;
    _destinationId = widget.accounts
        .firstWhere((account) => account.id != _sourceId)
        .id;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Account _account(String id) =>
      widget.accounts.firstWhere((item) => item.id == id);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final source = _account(_sourceId);
      final amount = Money.fromMajorUnits(
        _amountController.text,
        currency: source.availableBalance.currency,
      );
      if (amount.minorUnits > source.availableBalance.minorUnits) {
        throw const FormatException('El monto supera el saldo disponible.');
      }
      final transfer = await widget.createTransfer(
        sourceAccountId: _sourceId,
        destinationAccountId: _destinationId,
        amount: amount,
        reference: _referenceController.text.trim(),
        idempotencyKey:
            'mobile-${DateTime.now().toUtc().microsecondsSinceEpoch}',
      );
      if (!mounted) return;
      await _showSuccess(transfer);
      if (mounted) Navigator.of(context).pop(true);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on AppException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on Object {
      if (mounted) {
        setState(() => _error = 'No pudimos crear la transferencia.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccess(Transfer transfer) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF00A878),
          size: 52,
        ),
        title: const Text('Transferencia completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatMoney(transfer.amount),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Operación ${transfer.id.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = _account(_sourceId);
    final destinationAccounts = widget.accounts
        .where((item) => item.id != _sourceId)
        .toList();
    if (!destinationAccounts.any((item) => item.id == _destinationId)) {
      _destinationId = destinationAccounts.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva transferencia')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Entre tus cuentas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'La operación usa datos ficticios y una clave de idempotencia única.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _sourceId,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta de origen',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: widget.accounts.map(_accountItem).toList(),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _sourceId = value!),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 0, 16),
                  child: Text(
                    'Disponible: ${formatMoney(source.availableBalance)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                DropdownButtonFormField<String>(
                  key: ValueKey(_sourceId),
                  initialValue: _destinationId,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta de destino',
                    prefixIcon: Icon(Icons.savings_outlined),
                  ),
                  items: destinationAccounts.map(_accountItem).toList(),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _destinationId = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  enabled: !_submitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixText: 'S/ ',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    try {
                      Money.fromMajorUnits(value ?? '');
                      return null;
                    } on FormatException catch (error) {
                      return error.message;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenceController,
                  enabled: !_submitting,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Referencia (opcional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                if (_error case final error?) ...[
                  const SizedBox(height: 4),
                  Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                  label: Text(_submitting ? 'Procesando...' : 'Transferir'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _accountItem(Account account) {
    return DropdownMenuItem(
      value: account.id,
      child: Text('${account.alias} · ${account.maskedNumber}'),
    );
  }
}
