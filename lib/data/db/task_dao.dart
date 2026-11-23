import 'package:drift/drift.dart';
import 'app_database.dart';
import 'task_table.dart';

part 'task_dao.g.dart';

/// Estadísticas de una semana.
class WeekStats {
  final int total;
  final int completed;
  final int rescheduled;
  final Map<String, int> completedByDay; // 'yyyy-MM-dd' → count
  final Map<String, int> totalByDay; // 'yyyy-MM-dd' → count

  const WeekStats({
    required this.total,
    required this.completed,
    required this.rescheduled,
    required this.completedByDay,
    required this.totalByDay,
  });

  factory WeekStats.fromTasks(List<Task> all) {
    final total = all.length;
    final completed = all.where((t) => t.isDone).length;
    final rescheduled = all.where((t) => t.rescheduledCount > 0).length;

    final completedByDay = <String, int>{};
    final totalByDay = <String, int>{};

    for (final t in all) {
      totalByDay[t.date] = (totalByDay[t.date] ?? 0) + 1;
      if (t.isDone) {
        completedByDay[t.date] = (completedByDay[t.date] ?? 0) + 1;
      }
    }

    return WeekStats(
      total: total,
      completed: completed,
      rescheduled: rescheduled,
      completedByDay: completedByDay,
      totalByDay: totalByDay,
    );
  }

  int get remaining => total - completed;
  double get completionRate => total == 0 ? 0.0 : completed / total;
}

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  // ── Streams ─────────────────────────────────────────────────────────────

  /// Pendientes de un día ordenados: con hora → todo el día → hechos.
  Stream<List<Task>> watchByDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..orderBy([
            // Hechos al final
            (t) => OrderingTerm(expression: t.isDone),
            // Sin hora (null) después de los que tienen hora
            (t) => OrderingTerm(
                expression: t.timeMinutes,
                mode: OrderingMode.asc,
                nulls: NullsOrder.last),
          ]))
        .watch();
  }

  /// Atrasados: fecha < today y no hechos, del más antiguo al más reciente.
  Stream<List<Task>> watchOverdue(String today) {
    return (select(tasks)
          ..where((t) => t.date.isSmallerThanValue(today) & t.isDone.not())
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .watch();
  }

  /// Pendientes entre dos fechas (inclusive).
  Stream<List<Task>> watchBetween(String start, String end) {
    return (select(tasks)
          ..where(
              (t) => t.date.isBetweenValues(start, end))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date),
            (t) => OrderingTerm(expression: t.isDone),
            (t) => OrderingTerm(
                expression: t.timeMinutes,
                nulls: NullsOrder.last),
          ]))
        .watch();
  }

  // ── One-shot queries ─────────────────────────────────────────────────────

  Future<List<Task>> getByDate(String date) {
    return (select(tasks)
          ..where((t) => t.date.equals(date))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isDone),
            (t) => OrderingTerm(
                expression: t.timeMinutes, nulls: NullsOrder.last),
          ]))
        .get();
  }

  Future<List<Task>> getOverdue(String today) {
    return (select(tasks)
          ..where((t) => t.date.isSmallerThanValue(today) & t.isDone.not())
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
  }

  Future<List<Task>> getBetween(String start, String end) {
    return (select(tasks)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .get();
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  Future<void> insertTask(TasksCompanion entry) async {
    await into(tasks).insert(entry);
  }

  Future<void> updateTask(TasksCompanion entry) async {
    await (update(tasks)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> deleteTask(String id) async {
    await (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setDone(String id, bool done, DateTime? completedAt) async {
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isDone: Value(done),
        completedAt: Value(completedAt),
      ),
    );
  }

  Future<void> reschedule(String id, String newDate) async {
    final task = await (select(tasks)..where((t) => t.id.equals(id))).getSingle();
    await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        date: Value(newDate),
        rescheduledCount: Value(task.rescheduledCount + 1),
      ),
    );
  }

  /// Mueve todos los atrasados a [today] sumando rescheduledCount.
  Future<void> rescheduleAllOverdue(String today) async {
    final overdue = await getOverdue(today);
    for (final task in overdue) {
      await (update(tasks)..where((t) => t.id.equals(task.id))).write(
        TasksCompanion(
          date: Value(today),
          rescheduledCount: Value(task.rescheduledCount + 1),
        ),
      );
    }
  }

  // ── Estadísticas ─────────────────────────────────────────────────────────

  Future<WeekStats> statsForWeek(String start, String end) async {
    final all = await getBetween(start, end);
    return WeekStats.fromTasks(all);
  }
}
