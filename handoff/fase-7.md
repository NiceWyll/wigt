# Handoff Fase 7 — Revisión Semanal

## 1. Resumen de lo realizado
- Implementada la pantalla completa de Revisión Semanal (`lib/features/review/review_screen.dart`, ruta `/review/:weekStart`).
- Cálculo e integración de estadísticas de la semana (`WeekStats.fromTasks`):
  - Porcentaje de avance y formato "X de Y completados".
  - Barra de progreso global (`WigtProgressBar`).
  - Comparación con la semana anterior (+N más completados, -N menos, o mismo número).
  - Contador de pendientes restantes ("Sin hacer").
  - Contador de pendientes reprogramados ("Reprogramados", `rescheduledCount > 0`) con estilo ámbar (`AppColors.warning`).
  - Desglose de avance diario ("Barras por día") con 7 columnas para LUN a DOM, con alturas proporcionales, conteo `completados/total` y navegación táctil al día.
- Manejo seguro de división entre cero cuando la semana no tiene pendientes registrados (`stats.total == 0` devuelve 0.0 y muestra un estado vacío sin errores).
- Navegación entre semanas pasadas y futuras con flechas `<` y `>` y botón de retorno rápido "Esta semana".
- Enrutamiento GoRouter en `lib/core/router/app_router.dart` con acceso desde `WeekScreen` (botón de analíticas) y desde la notificación dominical.
- Pruebas unitarias de estadísticas y pruebas de widgets creadas en `test/features/review_screen_test.dart`.

## 2. Archivos creados o modificados
- `lib/features/review/review_screen.dart`: Pantalla completa de revisión semanal con diseño responsive, Hero card, comparación, métricas y desglose diario.
- `lib/data/db/task_dao.dart`: Agregado constructor de fábrica `WeekStats.fromTasks(List<Task> all)` para reutilización y cómputo reactivo.
- `lib/core/time/lima_time.dart`: Agregado helper `shortDayName(int weekday)` para etiquetas de días abreviados.
- `lib/core/router/app_router.dart`: Integración de la ruta `/review/:weekStart` hacia `ReviewScreen`.
- `test/features/review_screen_test.dart`: Tests unitarios y de widgets para estadísticas, división por cero, visualización de datos y navegación entre semanas.

## 3. Criterio de completado
- [x] Los números coinciden con los pendientes reales de esa semana.
- [x] Los pasados a otro día (`rescheduledCount > 0`) y los sin hacer (`remaining`) se cuentan bien.
- [x] Semana sin pendientes muestra un estado vacío correcto, sin dividir por cero.

## 4. Estado de validación
- `flutter analyze`: 0 issues found.
- `flutter test`: Todos los tests pasan.

