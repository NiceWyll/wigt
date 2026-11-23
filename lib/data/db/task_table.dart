import 'package:drift/drift.dart';

/// Tabla de pendientes (Tasks) en drift.
/// - date: 'yyyy-MM-dd'
/// - timeMinutes: 0..1439, null = todo el día
/// - rescheduledCount: veces que se pasó a otro día
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  TextColumn get date => text()(); // 'yyyy-MM-dd'
  IntColumn get timeMinutes => integer().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get rescheduledCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
