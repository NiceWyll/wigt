import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/core/theme/app_theme.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/data/db/task_repository.dart';
import 'package:wigt/data/holidays/holiday_model.dart';
import 'package:wigt/data/holidays/holiday_providers.dart';
import 'package:wigt/features/calendar/calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ── Pruebas del JSON de feriados ──────────────────────────────────────────

  group('Feriados de Perú (JSON oficial)', () {
    test('JSON tiene verifiedOn y los feriados de diciembre 2026 confirmados', () async {
      final jsonStr = await rootBundle.loadString('assets/holidays/holidays_pe.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final list = (data['holidays'] as List)
          .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
          .toList();

      final map = {for (final h in list) h.date: h};

      // Feriados confirmados 2026 según el README
      final dec8 = map['2026-12-08'];
      expect(dec8, isNotNull);
      expect(dec8!.name, 'Inmaculada Concepción');
      expect(dec8.provisional, false);
      expect(dec8.verifiedOn, isNotNull);

      final dec9 = map['2026-12-09'];
      expect(dec9, isNotNull);
      expect(dec9!.name, 'Batalla de Ayacucho');
      expect(dec9.provisional, false);
      expect(dec9.verifiedOn, isNotNull);

      final dec25 = map['2026-12-25'];
      expect(dec25, isNotNull);
      expect(dec25!.name, 'Navidad');
      expect(dec25.provisional, false);
      expect(dec25.verifiedOn, isNotNull);

      // Feriados de 2027 marcados como provisionales según el README
      final holidays2027 = list.where((h) => h.date.startsWith('2027-')).toList();
      expect(holidays2027.isNotEmpty, true);
      for (final h in holidays2027) {
        expect(h.provisional, true, reason: '${h.date} debe ser provisional en 2027');
      }
    });
  });

  // ── Pruebas de la pantalla Calendario ──────────────────────────────────────

  Widget createWidgetUnderTest(Widget child, [Map<String, Holiday>? holidays]) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        if (holidays != null)
          holidaysMapProvider.overrideWith((ref) => Future.value(holidays)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  testWidgets('Calendario muestra cuadrícula y días de la semana (L M X J V S D)', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const CalendarScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('L'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
    expect(find.text('V'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Calendario navega meses adelante y atrás', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const CalendarScreen()));
    await tester.pumpAndSettle();

    final nextBtn = find.byTooltip('Mes siguiente');
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // Debe mostrar botón "Hoy" para regresar
    expect(find.text('Hoy'), findsOneWidget);

    final prevBtn = find.byTooltip('Mes anterior');
    await tester.tap(prevBtn);
    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Un día con feriado y pendientes muestra ambas marcas y detalle correcto', (tester) async {
    // 2026-12-08 es feriado confirmado: Inmaculada Concepción
    await repo.createTask(
      title: 'Tarea del feriado',
      date: '2026-12-08',
    );

    final testHolidays = {
      '2026-12-08': const Holiday(
        date: '2026-12-08',
        name: 'Inmaculada Concepción',
        type: 'feriado',
      ),
    };

    await tester.pumpWidget(createWidgetUnderTest(const CalendarScreen(), testHolidays));
    await tester.pumpAndSettle();

    // Navegar a diciembre 2026
    final nextBtn = find.byTooltip('Mes siguiente');
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.text('Diciembre 2026'), findsOneWidget);

    // Tocar el día 8 de diciembre
    final day8 = find.text('8');
    expect(day8, findsOneWidget);
    await tester.tap(day8);
    await tester.pumpAndSettle();

    // La tarjeta de detalle debe mostrar el feriado y el pendiente
    expect(find.text('Feriado: Inmaculada Concepción'), findsOneWidget);
    expect(find.text('0 de 1 pendientes completados'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
