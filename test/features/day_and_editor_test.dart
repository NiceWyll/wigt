import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/core/theme/app_theme.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/data/db/task_repository.dart';
import 'package:wigt/features/day/day_screen.dart';
import 'package:wigt/features/editor/editor_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget createWidgetUnderTest(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  testWidgets('EditorScreen valida que el título no esté vacío', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      const EditorScreen(initialDate: '2026-11-24'),
    ));
    await tester.pumpAndSettle();

    final saveButton = find.text('Crear pendiente');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('El título no puede estar vacío'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('DayScreen muestra estado vacío cuando no hay tareas', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      const DayScreen(date: '2026-11-24'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sin pendientes este día'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('DayScreen muestra botón de agregar (+) en AppBar', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      const DayScreen(date: '2026-11-24'),
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Marcar hecho alterna el estado de la tarea', (tester) async {
    final repo = TaskRepository(db);
    final task = await repo.createTask(
      title: 'Hacer ejercicio',
      date: '2026-11-24',
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const DayScreen(date: '2026-11-24'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Hacer ejercicio'), findsOneWidget);

    final checkCircle = find.byType(GestureDetector).at(2);
    await tester.tap(checkCircle);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final updated = await repo.getByDate('2026-11-24');
      expect(updated.firstWhere((t) => t.id == task.id).isDone, true);
    });

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
