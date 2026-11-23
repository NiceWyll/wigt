import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wigt/data/db/app_database.dart';
import 'package:wigt/data/db/task_repository.dart';

AppDatabase _makeDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late TaskRepository repo;

  setUp(() {
    db = _makeDb();
    repo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ── Insertar y leer ──────────────────────────────────────────────────────

  test('insertar y leer por fecha', () async {
    await repo.createTask(
      title: 'Tarea de prueba',
      date: '2026-11-24',
    );

    final tasks = await db.taskDao.getByDate('2026-11-24');
    expect(tasks.length, 1);
    expect(tasks.first.title, 'Tarea de prueba');
    expect(tasks.first.isDone, false);
    expect(tasks.first.rescheduledCount, 0);
  });

  test('tarea con hora y notas se guarda correctamente', () async {
    await repo.createTask(
      title: 'Con hora',
      notes: 'Notas de prueba',
      date: '2026-11-24',
      timeMinutes: 540, // 09:00
    );
    final tasks = await db.taskDao.getByDate('2026-11-24');
    expect(tasks.first.timeMinutes, 540);
    expect(tasks.first.notes, 'Notas de prueba');
  });

  // ── Orden correcto ───────────────────────────────────────────────────────

  test('orden: con hora → todo el día → hechos', () async {
    // 1. Con hora 10:00
    await repo.createTask(title: 'Con hora', date: '2026-11-24', timeMinutes: 600);
    // 2. Todo el día
    await repo.createTask(title: 'Todo el día', date: '2026-11-24');
    // 3. Hecho
    final done = await repo.createTask(title: 'Hecho', date: '2026-11-24');
    await repo.setDone(done.id, done: true);

    final tasks = await db.taskDao.getByDate('2026-11-24');
    expect(tasks.length, 3);
    // Los hechos van al final (isDone = true → sort asc pone false primero)
    expect(tasks.last.isDone, true);
    // Con hora antes que sin hora
    final pending = tasks.where((t) => !t.isDone).toList();
    expect(pending.first.timeMinutes, 600);
    expect(pending.last.timeMinutes, null);
  });

  // ── Atrasados ────────────────────────────────────────────────────────────

  test('watchOverdue devuelve solo fechas anteriores a hoy no hechos', () async {
    // Atrasado (ayer)
    await repo.createTask(title: 'Atrasado', date: '2026-11-01');
    // Hoy → no atrasado
    await repo.createTask(title: 'Hoy', date: '2026-11-24');
    // Futuro → no atrasado
    await repo.createTask(title: 'Futuro', date: '2026-11-25');
    // Atrasado pero hecho → no aparece
    final done = await repo.createTask(title: 'AtrasadoHecho', date: '2026-11-01');
    await repo.setDone(done.id, done: true);

    // today = 2026-11-24
    final overdue = await db.taskDao.getOverdue('2026-11-24');
    expect(overdue.length, 1);
    expect(overdue.first.title, 'Atrasado');
    expect(overdue.first.isDone, false);
  });

  // ── Reschedule ───────────────────────────────────────────────────────────

  test('reschedule cambia fecha y suma rescheduledCount', () async {
    final task = await repo.createTask(title: 'Mover', date: '2026-11-01');
    expect(task.rescheduledCount, 0);

    await repo.reschedule(task.id, '2026-11-24');
    final tasks = await db.taskDao.getByDate('2026-11-24');
    final moved = tasks.firstWhere((t) => t.id == task.id);
    expect(moved.date, '2026-11-24');
    expect(moved.rescheduledCount, 1);
  });

  test('rescheduleAllOverdue mueve todos los atrasados', () async {
    await repo.createTask(title: 'A1', date: '2026-11-01');
    await repo.createTask(title: 'A2', date: '2026-11-02');
    final done = await repo.createTask(title: 'A3Done', date: '2026-11-01');
    await repo.setDone(done.id, done: true);

    await repo.rescheduleAllOverdue('2026-11-24');

    final today = await db.taskDao.getByDate('2026-11-24');
    final moved = today.where((t) => !t.isDone).toList();
    expect(moved.length, 2);
    for (final t in moved) {
      expect(t.rescheduledCount, 1);
    }
  });

  // ── setDone ──────────────────────────────────────────────────────────────

  test('setDone registra completedAt', () async {
    final task = await repo.createTask(title: 'Hecho', date: '2026-11-24');
    await repo.setDone(task.id, done: true);
    final tasks = await db.taskDao.getByDate('2026-11-24');
    final t = tasks.first;
    expect(t.isDone, true);
    expect(t.completedAt, isNotNull);
  });

  test('desmarcar hecho limpia completedAt', () async {
    final task = await repo.createTask(title: 'Hecho', date: '2026-11-24');
    await repo.setDone(task.id, done: true);
    await repo.setDone(task.id, done: false);
    final tasks = await db.taskDao.getByDate('2026-11-24');
    expect(tasks.first.isDone, false);
    expect(tasks.first.completedAt, isNull);
  });

  // ── statsForWeek ─────────────────────────────────────────────────────────

  test('statsForWeek devuelve totales correctos', () async {
    // 3 tareas: 2 hechas, 1 pendiente, 1 reprogramada
    final t1 = await repo.createTask(title: 'T1', date: '2026-11-23');
    await repo.setDone(t1.id, done: true);

    final t2 = await repo.createTask(title: 'T2', date: '2026-11-24');
    await repo.setDone(t2.id, done: true);

    // reprogramada (rescheduledCount > 0)
    final t3 = await repo.createTask(title: 'T3', date: '2026-11-01');
    await repo.reschedule(t3.id, '2026-11-25'); // ahora en la semana

    // fuera del rango
    await repo.createTask(title: 'Fuera', date: '2026-11-30');

    final stats = await repo.statsForWeek('2026-11-23', '2026-11-29');
    expect(stats.total, 3);
    expect(stats.completed, 2);
    expect(stats.rescheduled, 1);
    expect(stats.remaining, 1);
    expect(stats.completionRate, closeTo(0.666, 0.001));
    expect(stats.completedByDay['2026-11-23'], 1);
    expect(stats.completedByDay['2026-11-24'], 1);
    expect(stats.totalByDay['2026-11-25'], 1);
  });

  test('statsForWeek sin pendientes no divide por cero', () async {
    final stats = await repo.statsForWeek('2026-11-23', '2026-11-29');
    expect(stats.total, 0);
    expect(stats.completionRate, 0.0);
  });

  // ── watchBetween ─────────────────────────────────────────────────────────

  test('watchBetween devuelve tareas en el rango', () async {
    await repo.createTask(title: 'En rango', date: '2026-11-24');
    await repo.createTask(title: 'Fuera', date: '2026-12-01');

    final list = await db.taskDao.getBetween('2026-11-23', '2026-11-29');
    expect(list.length, 1);
    expect(list.first.title, 'En rango');
  });
}
