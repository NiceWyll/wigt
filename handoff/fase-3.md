HANDOFF — Fase 3 completada
- Hecho:
  - Pantalla `TodayScreen` (`/today`) como pantalla principal de la app con saludo y fecha en horario de Lima (America/Lima).
  - Sección interactiva `OverdueSection` con estética de advertencia sobria (borde ámbar 1px, background translúcido, sin emojis):
    - Contador de pendientes atrasados.
    - Botón "Pasar todos a hoy" con diálogo de confirmación que invoca `rescheduleAllOverdue(today)`.
    - Cada ítem atrasado cuenta con círculo de completar, título, fecha original ('Era para el LUN 24'), botón "Pasar a hoy" y botón "Elegir otro día" con selector de fecha `showDatePicker`.
    - La sección se oculta completamente cuando no hay pendientes atrasados.
  - Lista de pendientes de hoy con soporte para completar/desmarcar con vibración háptica, eliminación con deslizar y botón de deshacer en SnackBar.
  - Campo rápido `QuickAddField` al fondo para añadir pendientes a hoy con un toque o tecla Enter.
  - Actualizada la ruta inicial `/today` en `app_router.dart`.
  - 4 tests dedicados a la lógica de atrasados y pantalla Hoy en `test/features/today_and_overdue_test.dart`.
  - 35/35 tests pasando en total. `flutter analyze` limpio sin advertencias ni errores.
- Archivos creados/modificados:
  - `lib/features/today/today_screen.dart`
  - `lib/features/today/widgets/overdue_section.dart`
  - `lib/core/router/app_router.dart`
  - `test/features/today_and_overdue_test.dart`
  - `handoff/fase-3.md`
- Paquetes nuevos: ninguno.
- Decisiones tomadas:
  - Para asegurar tests 100% deterministas en flutter_test se añadieron `ValueKey` explícitos en los botones de acción rápida de `OverdueSection`.
- Pendiente / deuda técnica: ninguna.
- iOS: requiere Mac con Xcode — no compilado en este entorno
- Cómo verificar:
  flutter analyze   → "No issues found"
  flutter test      → 35/35 passed

