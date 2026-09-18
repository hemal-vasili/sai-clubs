import 'package:flutter_test/flutter_test.dart';

import 'package:sai_clubs/main.dart';

void main() {
  testWidgets('SaiClubs app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SaiClubsApp());

    expect(find.text('SaiClubs'), findsWidgets);
  });
}