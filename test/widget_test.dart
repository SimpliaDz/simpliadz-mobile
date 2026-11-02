import 'package:flutter_test/flutter_test.dart';
import 'package:simpliadz_mobile/app/app.dart';

void main() {
  testWidgets('displays the authentication entry screen', (tester) async {
    await tester.pumpWidget(const SimpliaDzApp());

    expect(find.text('SimpliaDz'), findsOneWidget);
    expect(find.text('Sign in to your business'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
