import 'package:flutter_test/flutter_test.dart';
import 'package:openbank_mobile/shared/domain/money.dart';

void main() {
  group('Money.fromMajorUnits', () {
    test('converts decimal text without floating point arithmetic', () {
      expect(
        Money.fromMajorUnits('1250.50'),
        const Money(minorUnits: 125050, currency: 'PEN'),
      );
      expect(
        Money.fromMajorUnits('10,5'),
        const Money(minorUnits: 1050, currency: 'PEN'),
      );
    });

    test('rejects zero, negative and more than two decimals', () {
      expect(() => Money.fromMajorUnits('0'), throwsFormatException);
      expect(() => Money.fromMajorUnits('-10'), throwsFormatException);
      expect(() => Money.fromMajorUnits('1.999'), throwsFormatException);
    });
  });
}
