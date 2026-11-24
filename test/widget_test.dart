import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:odeveharita/main.dart';

void main() {
  testWidgets('App starts on the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Etkinlik Planlayıcı'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
