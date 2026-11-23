import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../time/lima_time.dart';
import '../../data/db/task_repository.dart';
import '../../data/settings/settings_service.dart';

/// Servicio de notificaciones locales para Wigt.
/// Implementa la programación por ventana de 7 a 14 días y las reglas de texto oficiales.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String channelId = 'wigt_reminders';
  static const String channelName = 'Recordatorios Wigt';
  static const String channelDescription =
      'Resumen de la mañana y revisión semanal de tareas';

  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTapped,
  }) async {
    if (_initialized) return;

    LimaTime.init();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );

    _initialized = true;
  }

  /// Solicita permisos de forma amable.
  Future<bool> requestPermissions() async {
    try {
      bool granted = false;

      // Android 13+
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final res = await androidImpl.requestNotificationsPermission();
        granted = res ?? false;
      }

      // iOS
      final darwinImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (darwinImpl != null) {
        final res = await darwinImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = res ?? false;
      }

      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Construye el texto del resumen de la mañana según la sección 6 del README:
  /// - Ninguno: "Hoy no tienes pendientes"
  /// - Con atrasados: "Hoy tienes N pendientes y M atrasados"
  /// - Con hora: "Hoy tienes N pendientes · el primero a las HH:mm"
  /// - Sin hora: "Hoy tienes N pendientes"
  static String buildMorningSummaryText({
    required int pendingCount,
    int? earliestTimeMinutes,
    int overdueCount = 0,
  }) {
    if (pendingCount == 0 && overdueCount == 0) {
      return 'Hoy no tienes pendientes';
    }

    if (overdueCount > 0) {
      return 'Hoy tienes $pendingCount pendientes y $overdueCount atrasados';
    }

    if (earliestTimeMinutes != null) {
      final timeStr = LimaTime.minutesToHHmm(earliestTimeMinutes);
      return 'Hoy tienes $pendingCount pendientes · el primero a las $timeStr';
    }

    return 'Hoy tienes $pendingCount pendientes';
  }

  /// Reprograma la ventana de los próximos 7 días en zona horaria America/Lima.
  /// Se ejecuta al abrir la app, cambiar tareas o modificar ajustes.
  Future<void> scheduleWindow({
    required TaskRepository repo,
    required SettingsState settings,
  }) async {
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // En entornos de prueba o plataformas sin soporte nativo de notificaciones
      return;
    }

    final today = LimaTime.todayLima();
    final overdueList = await repo.getOverdue(today);
    final overdueCount = overdueList.length;

    // Programar ventana de 7 días
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = LimaTime.addDays(today, dayOffset);
      final tasks = await repo.getByDate(targetDate);
      final pendingTasks = tasks.where((t) => !t.isDone).toList();

      int? earliestMinutes;
      final timedTasks = pendingTasks.where((t) => t.timeMinutes != null).toList();
      if (timedTasks.isNotEmpty) {
        timedTasks.sort((a, b) => a.timeMinutes!.compareTo(b.timeMinutes!));
        earliestMinutes = timedTasks.first.timeMinutes;
      }

      // 1. Resumen de la mañana (si está activado)
      if (settings.morningSummaryEnabled) {
        final summaryText = buildMorningSummaryText(
          pendingCount: pendingTasks.length,
          earliestTimeMinutes: earliestMinutes,
          overdueCount: dayOffset == 0 ? overdueCount : 0,
        );

        final scheduledTime = _buildScheduleDateTime(
          targetDate,
          settings.morningSummaryMinutes,
        );

        // Solo programar si la hora está en el futuro
        if (scheduledTime.isAfter(LimaTime.nowLima())) {
          try {
            await _plugin.zonedSchedule(
              dayOffset, // ID 0..6
              'Wigt · Resumen del día',
              summaryText,
              scheduledTime,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channelId,
                  channelName,
                  channelDescription: channelDescription,
                  importance: Importance.defaultImportance,
                  priority: Priority.defaultPriority,
                ),
                iOS: const DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: '/today',
            );
          } catch (_) {}
        }
      }

      // 2. Revisión semanal si el día es Domingo
      final parsedDate = DateTime.tryParse(targetDate);
      if (parsedDate != null && parsedDate.weekday == DateTime.sunday) {
        if (settings.weeklyReviewEnabled) {
          final weekStart = LimaTime.startOfWeek(targetDate);
          final stats = await repo.statsForWeek(weekStart, targetDate);

          final scheduledSunday = _buildScheduleDateTime(
            targetDate,
            settings.weeklyReviewMinutes,
          );

          if (scheduledSunday.isAfter(LimaTime.nowLima())) {
            try {
              await _plugin.zonedSchedule(
                100 + dayOffset, // ID único
                'Wigt · Revisión semanal',
                'Tu semana: ${stats.completed} de ${stats.total} completados',
                scheduledSunday,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channelId,
                    channelName,
                    channelDescription: channelDescription,
                    importance: Importance.defaultImportance,
                    priority: Priority.defaultPriority,
                  ),
                  iOS: const DarwinNotificationDetails(
                    presentAlert: true,
                    presentBadge: true,
                    presentSound: true,
                  ),
                ),
                androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
                payload: '/review/$weekStart',
              );
            } catch (_) {}
          }
        }
      }
    }
  }

  tz.TZDateTime _buildScheduleDateTime(String dateStr, int minutesFromMidnight) {
    return LimaTime.tzDateTime(dateStr, minutesFromMidnight);
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
