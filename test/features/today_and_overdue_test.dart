import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/core/theme/app_theme.dart';
import 'package:wigt/core/time/lima_time.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/data/db/task_repository.dart';
import 'package:wigt/features/today/today_screen.dart';

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
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

  testWidgets('Sección Atrasados no se muestra si no hay tareas atrasadas', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const TodayScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Atrasados'), findsNothing);
    expect(find.text('Sin pendientes hoy'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Pendiente de ayer aparece en Atrasados y al pasar a hoy aparece en Hoy', (tester) async {
    final today = LimaTime.todayLima();
    final yesterday = LimaTime.addDays(today, -1);

    // Crear tarea atrasada
    final overdueTask = await repo.createTask(
      title: 'Comprar leche ayer',
      date: yesterday,
    );

    await tester.pumpWidget(createWidgetUnderTest(const TodayScreen()));
    await tester.pumpAndSettle();

    // Debe mostrar la sección Atrasados con 1
    expect(find.text('Atrasados'), findsOneWidget);
    expect(find.text('Comprar leche ayer'), findsOneWidget);

    // Tocar botón "Pasar a hoy"
    final moveToTodayBtn = find.byTooltip('Pasar a hoy');
    expect(moveToTodayBtn, findsOneWidget);
    await tester.tap(moveToTodayBtn);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final updated = await repo.getByDate(today);
      expect(updated.any((t) => t.id == overdueTask.id), true);
      final overdueList = await repo.getOverdue(today);
      expect(overdueList.isEmpty, true);
    });

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Marcar hecho un atrasado lo quita de Atrasados', (tester) async {
    final today = LimaTime.todayLima();
    final yesterday = LimaTime.addDays(today, -1);

    final overdueTask = await repo.createTask(
      title: 'Llamar al médico',
      date: yesterday,
    );

    await tester.pumpWidget(createWidgetUnderTest(const TodayScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Llamar al médico'), findsOneWidget);

    // Marcar como hecho desde la sección de atrasados usando su clave específica
    final checkCircle = find.byKey(ValueKey('overdue_check_${overdueTask.id}'));
    expect(checkCircle, findsOneWidget);
    await tester.tap(checkCircle);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final overdueList = await repo.getOverdue(today);
      expect(overdueList.any((t) => t.id == overdueTask.id), false);
    });

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Pasar todos a hoy mueve todos los pendientes atrasados', (tester) async {
    final today = LimaTime.todayLima();
    final yesterday = LimaTime.addDays(today, -1);

    await repo.createTask(title: 'Tarea 1', date: yesterday);
    await repo.createTask(title: 'Tarea 2', date: yesterday);

    await tester.pumpWidget(createWidgetUnderTest(const TodayScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Atrasados'), findsOneWidget);
    expect(find.text('Pasar todos a hoy'), findsOneWidget);

    await tester.tap(find.text('Pasar todos a hoy'));
    await tester.pumpAndSettle();

    // Confirmar en el diálogo
    expect(find.text('¿Mover los 2 pendientes atrasados a la lista de hoy?'), findsOneWidget);
    await tester.tap(find.text('Pasar a hoy').last);
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final overdueList = await repo.getOverdue(today);
      expect(overdueList.isEmpty, true);
      final todayList = await repo.getByDate(today);
      expect(todayList.length, 2);
    });

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
