class Money {
  const Money({required this.minorUnits, required this.currency});

  factory Money.fromMajorUnits(String value, {String currency = 'PEN'}) {
    final normalized = value.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(normalized)) {
      throw const FormatException(
        'Ingresa un monto válido con hasta 2 decimales.',
      );
    }
    final parts = normalized.split('.');
    final whole = int.parse(parts.first);
    final fraction = parts.length == 1 ? '00' : parts.last.padRight(2, '0');
    final minorUnits = whole * 100 + int.parse(fraction);
    if (minorUnits <= 0) {
      throw const FormatException('El monto debe ser mayor que cero.');
    }
    return Money(minorUnits: minorUnits, currency: currency);
  }

  final int minorUnits;
  final String currency;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);
}
