import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const WigtApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(WigtApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
