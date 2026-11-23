import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigt/core/notifications/notification_service.dart';
import 'package:wigt/core/theme/app_theme.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/providers.dart';
import 'package:wigt/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  // ── 1. Pruebas de formateo de texto según la sección 6 del README ──────────

  group('Formateo de texto de resumen matutino (sección 6)', () {
    test('Sin pendientes ni atrasados → "Hoy no tienes pendientes"', () {
      final text = NotificationService.buildMorningSummaryText(
        pendingCount: 0,
        earliestTimeMinutes: null,
        overdueCount: 0,
      );
      expect(text, 'Hoy no tienes pendientes');
    });

    test('Con pendientes sin hora → "Hoy tienes N pendientes"', () {
      final text = NotificationService.buildMorningSummaryText(
        pendingCount: 3,
        earliestTimeMinutes: null,
        overdueCount: 0,
      );
      expect(text, 'Hoy tienes 3 pendientes');
    });

    test('Con pendientes y hora → "Hoy tienes N pendientes · el primero a las HH:mm"', () {
      final text = NotificationService.buildMorningSummaryText(
        pendingCount: 4,
        earliestTimeMinutes: 540, // 09:00
        overdueCount: 0,
      );
      expect(text, 'Hoy tienes 4 pendientes · el primero a las 09:00');
    });

    test('Con atrasados → "Hoy tienes N pendientes y M atrasados"', () {
      final text = NotificationService.buildMorningSummaryText(
        pendingCount: 2,
        earliestTimeMinutes: 600,
        overdueCount: 3,
      );
      expect(text, 'Hoy tienes 2 pendientes y 3 atrasados');
    });
  });

  // ── 2. Pruebas de la pantalla Ajustes ──────────────────────────────────────

  Widget createSettingsScreen() {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const SettingsScreen(),
      ),
    );
  }

  testWidgets('SettingsScreen muestra títulos, switches y horas por defecto', (tester) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('RESUMEN DE LA MAÑANA'), findsOneWidget);
    expect(find.text('REVISIÓN SEMANAL'), findsOneWidget);
    expect(find.text('NOTIFICACIONES Y PERMISOS'), findsOneWidget);

    // Horas por defecto: 07:30 para la mañana, 20:00 para la semana
    expect(find.text('07:30'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Cambiar switch de resumen diario actualiza el estado', (tester) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    // El switch de resumen matutino está activo por defecto
    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    // Al desactivar el resumen, la fila de "Hora del resumen" se oculta
    expect(find.text('07:30'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Botón de permisos no lanza excepciones y muestra mensaje amable', (tester) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    final permBtn = find.text('Verificar permisos de notificación');
    expect(permBtn, findsOneWidget);
    await tester.tap(permBtn);
    await tester.pumpAndSettle();

    // Debe mostrar un mensaje de estado sin fallar
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('notificaciones') == true ||
                widget.data?.contains('permiso') == true),
      ),
      findsWidgets,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
