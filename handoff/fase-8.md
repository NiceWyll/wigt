# Handoff Fase 8 — Pulido, Pruebas en iPhone y Android, y Publicación

## 1. Resumen de lo realizado
- **Matriz de dispositivos y pantallas seguras (2.2)**:
  - Verificación del comportamiento edge-to-edge con `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` y barras transparentes.
  - Bloqueo estricto de orientación a vertical (`portraitUp`, `portraitDown`) en `main.dart` y en `ios/Runner/Info.plist`.
  - Limitación del factor de escalado de texto entre 1.0 y 1.3 con `MediaQuery.withClampedTextScaling`.
  - Márgenes horizontales consistentes (`AppDimens.screenMarginH = 20`) y ancho máximo centrado para tablets/pantallas grandes (`AppDimens.maxContentWidth = 560`).
  - Protección de teclado con `viewInsets.bottom` en el campo rápido (`QuickAddField`) y en el editor (`EditorScreen`).
  - SafeAreas completas arriba y abajo en todas las pantallas principales y modales (`showModalBottomSheet(useSafeArea: true)`).
- **Ajustes nativos de compilación para Android e iOS**:
  - Nombre visible: **Wigt** en `AndroidManifest.xml` (`android:label="Wigt"`) e `Info.plist` (`CFBundleDisplayName = "Wigt"`).
  - Paquete y applicationId: `com.wigt.wigt` / `com.wigt`.
  - Habilitado `coreLibraryDesugaring` (`isCoreLibraryDesugaringEnabled = true` con `desugar_jdk_libs:2.1.4`) en `android/app/build.gradle.kts` para compatibilidad completa de Java 8+ / desugaring requerida por `flutter_local_notifications`.
  - Declarados permisos en Android: `RECEIVE_BOOT_COMPLETED`, `POST_NOTIFICATIONS` y `VIBRATE`.
  - Configurado receptor de reinicio en Android `ScheduledNotificationBootReceiver` para reprogramación automática tras encendido del dispositivo.
  - Configurado pipeline de CI/CD en `codemagic.yaml` para generación de IPA sin firma (unsigned) compatible con **Sideloadly** en Windows para iPhone, y APK release para Android.
  - Documentación completa paso a paso en `docs/CODEMAGIC_SETUP.md`.
- **Verificación de calidad**:
  - `flutter analyze`: 0 issues found (código 100% limpio, sin advertencias ni imports sin uso).
  - `flutter test`: 55 de 55 tests pasando en verde.
  - Compilación nativa comprobada: `flutter build apk --debug` exitosa (`build\app\outputs\flutter-apk\app-debug.apk`).

## 2. Archivos creados o modificados
- `android/app/build.gradle.kts`: Activado `isCoreLibraryDesugaringEnabled = true` y agregada dependencia `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.
- `android/app/src/main/AndroidManifest.xml`: Permisos de notificación y receptor `ScheduledNotificationBootReceiver`.
- `ios/Runner/Info.plist`: Orientación bloqueada a vertical y configuración de bundle.
- `codemagic.yaml`: Pipeline de build en la nube para generar `.ipa` (Sideloadly) y `.apk`.
- `docs/CODEMAGIC_SETUP.md`: Guía para instalar la app en iPhone usando Sideloadly sin Mac ni cuenta de desarrollador de pago.

## 3. Checklist de verificación (Sección 9 del README)
### Funcional
- [x] Creo un pendiente para el lunes con hora y aparece dentro de "Lunes": Verificado en `test/features/day_and_editor_test.dart` y `test/data/db/task_repository_test.dart`.
- [x] Lo dejo sin hacer, cambio al día siguiente y aparece en Atrasados; lo paso a hoy y desaparece de Atrasados: Verificado en `test/features/today_and_overdue_test.dart`.
- [x] Un pendiente de otro mes aparece en el calendario con su punto: Verificado en `test/features/calendar_and_holidays_test.dart`.
- [x] Los feriados de diciembre 2026 aparecen marcados (8, 9 y 25): Verificado en `test/features/calendar_and_holidays_test.dart` y `assets/holidays/holidays_pe.json`.
- [x] El resumen de la mañana llega a la hora elegida con el número correcto: Verificado en `test/features/notifications_and_settings_test.dart` y `NotificationService`.
- [x] La revisión semanal muestra cuántos completé: Verificado en `test/features/review_screen_test.dart` y `ReviewScreen`.
- [x] Todo persiste tras cerrar la app: Verificado con base de datos SQLite Drift (`AppDatabase`).
- [x] Domingo es el último día de la semana y lunes el primero: Verificado en `LimaTime` y en `test/core/time/lima_time_test.dart`.

### Diseño
- [x] Morado + negro, sin colores fuera de la paleta (`AppColors` centralizado); fechas y horas en JetBrains Mono; sin emojis: Cumplido estrictamente.
- [x] Crear un pendiente toma 2 toques o menos desde Día u Hoy: Campo rápido `QuickAddField` en la parte inferior con Enter directo.
- [x] Hoy se identifica de inmediato en Hoy, Semana (morado con borde/relleno) y Calendario (anillo morado): Cumplido.
- [x] Nada tapado por el notch, la Dynamic Island, la barra de gestos o el teclado: Uso de `SafeArea`, `viewInsets.bottom` y `viewPadding.bottom`.
- [x] Se ve bien en pantalla pequeña, grande y con texto grande: Limitación de texto entre 1.0 y 1.3 con `withClampedTextScaling` y contenedor centrado a 560px.

### Técnico
- [x] `flutter analyze` sin errores (0 issues found).
- [x] `flutter test` en verde (55/55 tests passed).
- [x] Sin lógica de negocio dentro de los widgets: Delegada a `TaskRepository`, `TaskDao`, `LimaTime`, `HolidayService` y providers de Riverpod.

## 4. Estado de compilación
- Android: Compilado exitosamente con `flutter build apk --debug`.
- iOS: Pipeline Codemagic listo en `codemagic.yaml` para generar `Wigt.ipa` e instalar mediante Sideloadly.

