import 'package:flutter_test/flutter_test.dart';

import 'package:gamelog/main.dart';

void main() {
  testWidgets('Login screen shows on launch', (tester) async {
    await tester.pumpWidget(const GameLogApp());

    expect(find.text('GameLog'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
