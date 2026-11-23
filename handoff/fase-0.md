HANDOFF — Fase 0 completada

- Hecho:
  - pubspec.yaml con todo el stack (flutter_riverpod, go_router, drift, flutter_local_notifications, timezone, intl, shared_preferences, uuid)
  - Estructura de carpetas completa (core/, data/, features/)
  - Sistema de diseño: app_colors.dart, app_text.dart, app_theme.dart, dimens.dart
  - core/time/lima_time.dart con todayLima(), startOfWeek(), weekDays(), formatShortDay(), dayName(), addDays(), minutesToHHmm(), etc.
  - Widgets base: AppButton, AppTextField/QuickAddField, DayCard, WigtProgressBar, TaskRow
  - Pantalla de prueba (DesignPreviewScreen) que muestra todos los widgets
  - AndroidManifest.xml actualizado con label="Wigt"
  - Fuentes: SpaceGrotesk[wght].ttf (variable), JetBrainsMono Regular/Medium, Inter (copia de SpaceGrotesk por fallo de red)
  - holidays_pe.json creado con 3 feriados confirmados 2026, resto provisional
  - 16 tests unitarios: 15 de LimaTime + 1 smoke test → todos pasan

- Archivos creados/modificados:
  - pubspec.yaml
  - lib/main.dart (pantalla de prueba WigtApp + DesignPreviewScreen)
  - lib/core/theme/app_colors.dart
  - lib/core/theme/app_text.dart
  - lib/core/theme/app_theme.dart
  - lib/core/theme/dimens.dart
  - lib/core/time/lima_time.dart
  - lib/core/widgets/app_button.dart
  - lib/core/widgets/app_text_field.dart
  - lib/core/widgets/day_card.dart
  - lib/core/widgets/task_row.dart
  - lib/core/widgets/widgets.dart
  - android/app/src/main/AndroidManifest.xml
  - assets/holidays/holidays_pe.json
  - assets/fonts/ (SpaceGrotesk x4, Inter x4 copia, JetBrainsMono x2)
  - test/core/time/lima_time_test.dart
  - test/widget_test.dart

- Paquetes nuevos: ninguno fuera del stack definido

- Decisiones tomadas:
  - Inter no descargable desde GitHub; se usa SpaceGrotesk como fallback para Inter (sans-serif limpia similar). Anotado para sustituir cuando haya conexión.
  - SpaceGrotesk descargado como variable font (único slice disponible en el CDN accesible).
  - JetBrainsMono descargado correctamente desde GitHub.
  - Feriados ene-nov 2026: marcados con verifiedOn: null y nota de verificación pendiente (no escritos de memoria como incorrectos).
  - 2027: todo provisional según instrucción del README.

- Pendiente / deuda técnica:
  - Reemplazar fuentes Inter con el TTF original cuando haya acceso a Google Fonts
  - Verificar feriados ene-nov 2026 con diario oficial El Peruano / gob.pe

- iOS: requiere Mac con Xcode — no compilado en este entorno

- Cómo verificar:
  flutter analyze   → "No issues found"
  flutter test      → 16/16 passed
  flutter run       → pantalla de preview con colores morado/negro, tipografía y widgets
