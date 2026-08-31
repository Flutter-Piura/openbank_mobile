import 'package:openbank_mobile/shared/domain/money.dart';

String formatMoney(Money money) {
  final symbol = switch (money.currency) {
    'PEN' => 'S/',
    'USD' => r'$',
    _ => money.currency,
  };
  final absolute = money.minorUnits.abs();
  final whole = (absolute ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final cents = (absolute % 100).toString().padLeft(2, '0');
  final sign = money.minorUnits < 0 ? '-' : '';
  return '$symbol $sign$whole.$cents';
}
