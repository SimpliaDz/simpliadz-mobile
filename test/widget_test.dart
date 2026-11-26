import 'package:flutter_test/flutter_test.dart';
import 'package:simplia_mobile/app/app.dart';

void main() {
  testWidgets('displays the authentication entry screen', (tester) async {
    await tester.pumpWidget(const SimpliaWearApp());

    expect(find.text('SimpliaWear'), findsOneWidget);
    expect(find.text('Sign in to your business'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
