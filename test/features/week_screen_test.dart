import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/core/theme/app_theme.dart';
import 'package:wigt/core/time/lima_time.dart';
import 'package:wigt/core/widgets/day_card.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/data/db/task_repository.dart';
import 'package:wigt/features/week/week_screen.dart';

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

  testWidgets('WeekScreen muestra 7 tarjetas (Lunes a Domingo)', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const WeekScreen()));
    await tester.pumpAndSettle();

    // Debe mostrar exactamente 7 DayCards
    expect(find.byType(DayCard), findsNWidgets(7));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('WeekScreen resalta el día de hoy correctamente en Lima', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const WeekScreen()));
    await tester.pumpAndSettle();

    final today = LimaTime.todayLima();
    final todayCardFinder = find.byWidgetPredicate(
      (widget) => widget is DayCard && widget.dateStr == today && widget.isToday == true,
    );
    expect(todayCardFinder, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Los contadores de la semana reflejan las tareas guardadas', (tester) async {
    final today = LimaTime.todayLima();
    final weekDays = LimaTime.weekDays(today);
    final monday = weekDays[0];

    // Crear 2 tareas el lunes (1 completada)
    final t1 = await repo.createTask(title: 'Tarea 1 lunes', date: monday);
    await repo.setDone(t1.id, done: true);
    await repo.createTask(title: 'Tarea 2 lunes', date: monday);

    await tester.pumpWidget(createWidgetUnderTest(const WeekScreen()));
    await tester.pumpAndSettle();

    final mondayCard = find.byWidgetPredicate(
      (widget) =>
          widget is DayCard &&
          widget.dateStr == monday &&
          widget.taskCount == 2 &&
          widget.completedCount == 1,
    );
    expect(mondayCard, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Navegación de semanas anterior y siguiente', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const WeekScreen()));
    await tester.pumpAndSettle();

    // Tocar semana anterior
    final prevBtn = find.byTooltip('Semana anterior');
    expect(prevBtn, findsOneWidget);
    await tester.tap(prevBtn);
    await tester.pumpAndSettle();

    // Tocar semana siguiente dos veces
    final nextBtn = find.byTooltip('Semana siguiente');
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // Al estar en semana futura debe aparecer el botón "Hoy" para volver
    expect(find.text('Hoy'), findsOneWidget);
    await tester.tap(find.text('Hoy'));
    await tester.pumpAndSettle();

    // Regresó a la semana actual (desaparece el botón "Hoy")
    expect(find.text('Hoy'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

