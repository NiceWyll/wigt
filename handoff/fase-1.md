HANDOFF — Fase 1 completada
- Hecho:
  - Tabla Drift `Tasks` configurada con id (uuid), title, notes, date ('yyyy-MM-dd'), timeMinutes (0..1439), isDone (bool), completedAt, rescheduledCount, createdAt.
  - `TaskDao` completo con streams y queries one-shot: watchByDate, watchOverdue, watchBetween, insertTask, updateTask, deleteTask, setDone, reschedule, rescheduleAllOverdue, statsForWeek.
  - `AppDatabase` con NativeDatabase en background y constructor forTesting en memoria.
  - `TaskRepository` como capa de dominio limpia entre UI y Drift.
  - Providers de Riverpod en `lib/data/db/providers.dart`.
  - Configurado `build.yaml` para limitar la compilación de drift_dev a `lib/data/db/**`.
  - 11 tests unitarios de datos en `test/data/db/task_repository_test.dart` cubriendo inserción, ordenamiento (con hora -> todo el día -> hechos), atrasados, reprogramación individual y masiva, setDone y stats de semana.
  - Total tests en verde: 27/27. `flutter analyze` con 0 issues.
- Archivos creados/modificados:
  - `lib/data/db/task_table.dart`
  - `lib/data/db/task_dao.dart`
  - `lib/data/db/app_database.dart`
  - `lib/data/db/app_database.g.dart`
  - `lib/data/db/task_dao.g.dart`
  - `lib/data/db/task_repository.dart`
  - `lib/data/db/providers.dart`
  - `build.yaml`
  - `pubspec.yaml` (actualizado drift/drift_dev a 2.35 para compatibilidad Dart 3.13)
  - `test/data/db/task_repository_test.dart`
  - `handoff/fase-1.md`
- Paquetes nuevos:
  - drift/drift_dev actualizados a ^2.35.0 para compatibilidad con analizador de Dart 3.13.
- Decisiones tomadas:
  - Eliminados generadores no requeridos (riverpod_generator) manteniendo flutter_riverpod limpio con Providers estándar.
  - Orden de tareas por día: hechos al final, y dentro de los no hechos primero con hora ascendente, luego todo el día.
- Pendiente / deuda técnica:
  - Ninguna.
- iOS: requiere Mac con Xcode — no compilado en este entorno
- Cómo verificar:
  flutter analyze   → "No issues found"
  flutter test      → 27/27 passed

