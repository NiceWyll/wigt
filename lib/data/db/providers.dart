import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/task_dao.dart';
import '../db/task_repository.dart';

/// Provider de la base de datos (singleton).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provider del repositorio de tareas.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TaskRepository(db);
});

/// Stream de tareas de un día.
final tasksByDateProvider =
    StreamProvider.family<List<Task>, String>((ref, date) {
  return ref.watch(taskRepositoryProvider).watchByDate(date);
});

/// Stream de tareas atrasadas.
final overdueTasksProvider =
    StreamProvider.family<List<Task>, String>((ref, today) {
  return ref.watch(taskRepositoryProvider).watchOverdue(today);
});

/// Stream de tareas entre dos fechas.
final tasksBetweenProvider =
    StreamProvider.family<List<Task>, ({String start, String end})>(
        (ref, range) {
  return ref.watch(taskRepositoryProvider).watchBetween(range.start, range.end);
});

/// Stats de semana.
final weekStatsProvider =
    FutureProvider.family<WeekStats, ({String start, String end})>(
        (ref, range) {
  return ref.watch(taskRepositoryProvider).statsForWeek(range.start, range.end);
});
