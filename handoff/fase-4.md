HANDOFF — Fase 4 completada
- Hecho:
  - Pantalla `WeekScreen` (`/week`):
    - Selector de semana con flechas izquierda/derecha y formateador de rango ('Semana del 24 al 30 de noviembre').
    - Botón de retorno rápido a "Hoy" cuando se está visualizando una semana pasada o futura.
    - Banner directo para acceder a la Revisión Semanal (`/review/:weekStart`).
    - 7 tarjetas de día `DayCard` (Lunes a Domingo) con fecha, conteo de tareas completadas/totales y barra de progreso animada `WigtProgressBar`.
    - Resaltado distintivo en morado (`AppColors.primary`) para el día de hoy según horario oficial de Lima.
    - Tocar cualquier tarjeta navega a la pantalla del día (`/day/:date`).
  - Barra de navegación inferior `MainScaffold` (`Hoy`, `Semana`, `Calendario`, `Ajustes`):
    - Integrada en `lib/core/router/app_router.dart` mediante `StatefulShellRoute.indexedStack`.
    - Respeta estrictamente las pantallas seguras (2.2) al incorporar `viewPadding.bottom` evitando choques con la barra de gestos de iPhone y botones de Android.
  - 4 tests unitarios de integración en `test/features/week_screen_test.dart` verificando las 7 tarjetas, el resaltado de hoy en Lima, los contadores por día y la navegación de semanas.
  - 39/39 tests pasando en total. `flutter analyze` 0 issues.
- Archivos creados/modificados:
  - `lib/features/week/week_screen.dart`
  - `lib/core/widgets/main_scaffold.dart`
  - `lib/core/router/app_router.dart`
  - `test/features/week_screen_test.dart`
  - `handoff/fase-4.md`
- Paquetes nuevos: ninguno.
- Decisiones tomadas:
  - Implementado `Column` con scroll suave dentro de `SingleChildScrollView` en lugar de ListView lazy para asegurar renderizado consistente y testabilidad de los 7 días de la semana.
- Pendiente / deuda técnica: ninguna.
- iOS: requiere Mac con Xcode — no compilado en este entorno
- Cómo verificar:
  flutter analyze   → "No issues found"
  flutter test      → 39/39 passed

