import 'package:flutter_test/flutter_test.dart';
import 'package:openbank_mobile/shared/domain/money.dart';
import 'package:openbank_mobile/shared/presentation/money_format.dart';

void main() {
  test('formats PEN deterministically without floating point arithmetic', () {
    expect(
      formatMoney(const Money(minorUnits: 575050, currency: 'PEN')),
      'S/ 5,750.50',
    );
    expect(
      formatMoney(const Money(minorUnits: -1000, currency: 'PEN')),
      'S/ -10.00',
    );
  });
}
