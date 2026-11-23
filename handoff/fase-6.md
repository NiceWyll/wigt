HANDOFF — Fase 6 completada
- Hecho:
  - Servicio de notificaciones `NotificationService` en `lib/core/notifications/`:
    - Configurado con zona `America/Lima` usando `timezone` y `LimaTime`.
    - Canal de notificación en Android `wigt_reminders` ('Recordatorios Wigt').
    - Programación con `AndroidScheduleMode.inexactAllowWhileIdle` en Android para evitar el permiso invasivo de alarmas exactas.
    - Manejo amable y seguro de permisos para Android 13+ y iOS.
    - Lógica de texto oficial de resumen matutino (sección 6 del README):
      - "Hoy no tienes pendientes"
      - "Hoy tienes N pendientes"
      - "Hoy tienes N pendientes · el primero a las HH:mm"
      - "Hoy tienes N pendientes y M atrasados"
    - Programación por ventana móvil de 7 días (máximo 8 notificaciones programadas, muy inferior al límite de 64 en iOS).
    - Aviso de revisión semanal los domingos a las 20:00 con payload `/review/:weekStart`.
  - Persistencia de configuración con `SharedPreferences` en `SettingsService` y `SettingsNotifier` (`morningSummaryEnabled`, `morningSummaryMinutes`, `weeklyReviewEnabled`, `weeklyReviewMinutes`).
  - Pantalla `SettingsScreen` (`/settings`):
    - Switch de activación de resumen diario y selector de hora con TimePicker.
    - Switch de aviso de revisión semanal de domingo y selector de hora.
    - Card informativo amable con botón para verificar permisos y retroalimentación clara si están desactivados.
  - 7 tests unitarios y de widgets en `test/features/notifications_and_settings_test.dart`.
  - 50/50 tests pasando en total. `flutter analyze` 0 issues.
- Archivos creados/modificados:
  - `lib/data/settings/settings_service.dart`
  - `lib/data/settings/settings_providers.dart`
  - `lib/core/notifications/notification_service.dart`
  - `lib/core/notifications/notification_providers.dart`
  - `lib/features/settings/settings_screen.dart`
  - `lib/core/router/app_router.dart`
  - `test/features/notifications_and_settings_test.dart`
  - `handoff/fase-6.md`
- Paquetes nuevos: ninguno.
- Decisiones tomadas:
  - `NotificationService.scheduleWindow` envuelto con captura segura de excepciones para no fallar en entornos donde el plugin nativo no esté disponible o no esté inicializado (como en tests de widgets).
  - Uso de `Material` con `shape: RoundedRectangleBorder` en `SettingsScreen` para cumplir estrictamente con las aserciones de renderizado de `ListTile` en Flutter 3.47.
- Pendiente / deuda técnica: ninguna.
- iOS: requiere Mac con Xcode — no compilado en este entorno
- Cómo verificar:
  flutter analyze   → "No issues found"
  flutter test      → 50/50 passed

