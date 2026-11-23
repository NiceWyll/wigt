import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/core/theme/app_theme.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/data/db/task_dao.dart';
import 'package:wigt/data/db/task_repository.dart';
import 'package:wigt/features/review/review_screen.dart';

void main() {
  group('WeekStats - Lógica estadística', () {
    test('Semana sin pendientes no divide por cero', () {
      final stats = WeekStats.fromTasks([]);
      expect(stats.total, 0);
      expect(stats.completed, 0);
      expect(stats.rescheduled, 0);
      expect(stats.remaining, 0);
      expect(stats.completionRate, 0.0);
    });

    test('Semana con tareas calcula totales, restantes y reprogramados', () {
      final now = DateTime.now();
      final tasks = [
        Task(
          id: '1',
          title: 'T1',
          notes: null,
          date: '2026-11-23',
          timeMinutes: null,
          isDone: true,
          completedAt: now,
          rescheduledCount: 0,
          createdAt: now,
        ),
        Task(
          id: '2',
          title: 'T2',
          notes: null,
          date: '2026-11-23',
          timeMinutes: null,
          isDone: true,
          completedAt: now,
          rescheduledCount: 0,
          createdAt: now,
        ),
        Task(
          id: '3',
          title: 'T3',
          notes: null,
          date: '2026-11-24',
          timeMinutes: null,
          isDone: true,
          completedAt: now,
          rescheduledCount: 2, // reprogramada
          createdAt: now,
        ),
        Task(
          id: '4',
          title: 'T4',
          notes: null,
          date: '2026-11-25',
          timeMinutes: null,
          isDone: false,
          completedAt: null,
          rescheduledCount: 0,
          createdAt: now,
        ),
        Task(
          id: '5',
          title: 'T5',
          notes: null,
          date: '2026-11-26',
          timeMinutes: null,
          isDone: false,
          completedAt: null,
          rescheduledCount: 0,
          createdAt: now,
        ),
      ];

      final stats = WeekStats.fromTasks(tasks);
      expect(stats.total, 5);
      expect(stats.completed, 3);
      expect(stats.remaining, 2);
      expect(stats.rescheduled, 1);
      expect(stats.completionRate, 0.6);
      expect(stats.totalByDay['2026-11-23'], 2);
      expect(stats.completedByDay['2026-11-23'], 2);
      expect(stats.totalByDay['2026-11-25'], 1);
      expect(stats.completedByDay['2026-11-25'], null);
    });
  });

  group('ReviewScreen Widget Tests', () {
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

    testWidgets('ReviewScreen muestra estado vacío sin errores cuando no hay tareas',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(const ReviewScreen(weekStart: '2026-11-23')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Revisión semanal'), findsOneWidget);
      expect(find.text('Sin pendientes esta semana'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('ReviewScreen muestra datos reales con porcentaje y barras',
        (tester) async {
      // Insertar 5 tareas: 3 hechas, 2 pendientes, 1 reprogramada
      final t1 = await repo.createTask(
        title: 'Tarea 1',
        date: '2026-11-23',
      );
      await repo.setDone(t1.id, done: true);

      final t2 = await repo.createTask(
        title: 'Tarea 2',
        date: '2026-11-23',
      );
      await repo.setDone(t2.id, done: true);

      final t3 = await repo.createTask(
        title: 'Tarea 3',
        date: '2026-11-24',
      );
      await repo.setDone(t3.id, done: true);
      await repo.reschedule(t3.id, '2026-11-24');

      await repo.createTask(
        title: 'Tarea 4',
        date: '2026-11-25',
      );
      await repo.createTask(
        title: 'Tarea 5',
        date: '2026-11-26',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(const ReviewScreen(weekStart: '2026-11-23')),
      );
      await tester.pumpAndSettle();

      // Verifica 60%
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('3 de 5 completados'), findsOneWidget);

      // Métricas: sin hacer (2) y reprogramados (1)
      expect(find.text('Sin hacer'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Reprogramados'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Sección avance por día
      expect(find.text('Avance por día'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('Navegación entre semanas actualiza el rango mostrado',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(const ReviewScreen(weekStart: '2026-11-23')),
      );
      await tester.pumpAndSettle();

      expect(find.text('23 al 29 de noviembre'), findsOneWidget);

      // Pulsar semana anterior
      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.pumpAndSettle();

      expect(find.text('16 al 22 de noviembre'), findsOneWidget);

      // Pulsar semana siguiente
      await tester.tap(find.byTooltip('Semana siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('23 al 29 de noviembre'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
