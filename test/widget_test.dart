import 'package:flutter_test/flutter_test.dart';
import 'package:openbank_mobile/main.dart';

void main() {
  testWidgets('shows the OpenBank start page', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('OpenBank'), findsOneWidget);
  });
}
