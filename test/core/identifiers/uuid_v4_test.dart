import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:openbank_mobile/core/identifiers/uuid_v4.dart';

void main() {
  test('generates a valid RFC 4122 UUID version 4', () {
    final uuid = generateUuidV4(random: Random(42));

    expect(
      uuid,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
