HANDOFF — Fase 5 completada
- Hecho:
  - Carga y procesamiento de feriados peruanos desde `assets/holidays/holidays_pe.json`:
    - Modelo `Holiday` con campos `date`, `name`, `type`, `provisional`, `verifiedOn`, `note`.
    - Servicio `HolidayService` y providers de Riverpod (`holidayServiceProvider`, `holidaysMapProvider`, `holidayForDateProvider`).
    - Verificados feriados 2026 (8 dic Inmaculada Concepción, 9 dic Batalla de Ayacucho, 25 dic Navidad).
    - Feriados de 2027 marcados con `provisional: true` conforme a la instrucción oficial del README.
  - Pantalla `CalendarScreen` (`/calendar`):
    - Cuadrícula mensual completa iniciando siempre en Lunes (`L M X J V S D`).
    - Cabecera con mes y año en español ("Noviembre 2026"), flechas de cambio de mes y botón de retorno a "Hoy".
    - Celdas con punto morado (`AppColors.primaryLight`) para tareas y punto ámbar (`AppColors.warning`) para feriados.
    - Ambos indicadores se muestran armónicamente sin romper el layout en días compartidos.
    - Anillo morado para el día de hoy y celda resaltada para el día seleccionado.
    - Tarjeta inferior de detalle del día seleccionado: fecha completa, etiqueta de feriado con badge, conteo de tareas y botón para abrir el día (`/day/:date`).
  - Etiquetas de feriado añadidas en `DayScreen` y `TodayScreen`.
  - 4 tests dedicados a feriados y calendario en `test/features/calendar_and_holidays_test.dart`.
  - 43/43 tests pasando en total. `flutter analyze` 0 issues.
- Archivos creados/modificados:
  - `lib/data/holidays/holiday_model.dart`
  - `lib/data/holidays/holiday_service.dart`
  - `lib/data/holidays/holiday_providers.dart`
  - `lib/features/calendar/calendar_screen.dart`
  - `lib/features/day/day_screen.dart`
  - `lib/features/today/today_screen.dart`
  - `lib/core/router/app_router.dart`
  - `test/features/calendar_and_holidays_test.dart`
  - `handoff/fase-5.md`
- Paquetes nuevos: ninguno.
- Decisiones tomadas:
  - Para soportar inyección en tests se permitió el override de `holidaysMapProvider` en ProviderScope.
- Pendiente / deuda técnica: ninguna.
- iOS: requiere Mac con Xcode — no compilado en este entorno
- Cómo verificar:
  flutter analyze   → "No issues found"
  flutter test      → 43/43 passed

