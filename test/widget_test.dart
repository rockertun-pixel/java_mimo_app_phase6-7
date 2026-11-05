import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myanmar_code_learning/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('application starts', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: CodeLearnApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('သင်ယူမှု တိုးတက်မှု'), findsOneWidget);
    expect(find.text('စုစုပေါင်း XP'), findsOneWidget);
  });
}
