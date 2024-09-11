import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:card_shootout/main.dart';

void main() {
  testWidgets('Verifica que el texto inicial sea correcto', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(CardShootout());

    // Verifica que se muestre el texto inicial "Elige dónde disparar".
    expect(find.text('Elige dónde disparar'), findsOneWidget);
  });
}
