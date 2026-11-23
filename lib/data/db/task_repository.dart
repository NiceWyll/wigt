import 'package:uuid/uuid.dart';
import '../db/app_database.dart';
import '../db/task_dao.dart';
import 'package:drift/drift.dart';

/// Repositorio de tareas — capa de dominio entre la UI y el DAO.
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  TaskDao get _dao => _db.taskDao;

  // ── Streams ─────────────────────────────────────────────────────────────

  Stream<List<Task>> watchByDate(String date) => _dao.watchByDate(date);

  Future<List<Task>> getByDate(String date) => _dao.getByDate(date);

  Stream<List<Task>> watchOverdue(String today) => _dao.watchOverdue(today);

  Future<List<Task>> getOverdue(String today) => _dao.getOverdue(today);

  Stream<List<Task>> watchBetween(String start, String end) =>
      _dao.watchBetween(start, end);

  // ── Writes ───────────────────────────────────────────────────────────────

  Future<Task> createTask({
    required String title,
    String? notes,
    required String date,
    int? timeMinutes,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();
    final companion = TasksCompanion.insert(
      id: id,
      title: title,
      notes: Value(notes),
      date: date,
      timeMinutes: Value(timeMinutes),
      createdAt: now,
    );
    await _dao.insertTask(companion);
    return (await _db.taskDao.getByDate(date)).firstWhere((t) => t.id == id);
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? notes,
    String? date,
    int? timeMinutes,
    bool? isDone,
    DateTime? completedAt,
    int? rescheduledCount,
  }) async {
    await _dao.updateTask(TasksCompanion(
      id: Value(id),
      title: title != null ? Value(title) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      date: date != null ? Value(date) : const Value.absent(),
      timeMinutes: timeMinutes != null ? Value(timeMinutes) : const Value.absent(),
      isDone: isDone != null ? Value(isDone) : const Value.absent(),
      completedAt: completedAt != null ? Value(completedAt) : const Value.absent(),
      rescheduledCount: rescheduledCount != null ? Value(rescheduledCount) : const Value.absent(),
    ));
  }

  Future<void> deleteTask(String id) => _dao.deleteTask(id);

  Future<void> setDone(String id, {required bool done}) async {
    final completedAt = done ? DateTime.now().toUtc() : null;
    await _dao.setDone(id, done, completedAt);
  }

  Future<void> reschedule(String id, String newDate) =>
      _dao.reschedule(id, newDate);

  Future<void> rescheduleAllOverdue(String today) =>
      _dao.rescheduleAllOverdue(today);

  Future<WeekStats> statsForWeek(String start, String end) =>
      _dao.statsForWeek(start, end);
}
