import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../time/lima_time.dart';
import '../../data/db/providers.dart';
import '../../data/db/app_database.dart';

/// Servicio para sincronizar los pendientes del día con el widget de la pantalla de inicio (Android / iOS).
class HomeWidgetService {
  static const String appGroupId = 'group.com.wigt.app';
  static const String androidWidgetName = 'WigtWidgetProvider';
  static const String iOSWidgetName = 'WigtWidget';

  /// Inicializa el grupo de apps para iOS y actualiza el widget si es posible.
  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('HomeWidget init error: $e');
    }
  }

  /// Actualiza los datos del widget con los pendientes de la fecha actual de Lima.
  static Future<void> updateTodayWidget(WidgetRef ref) async {
    try {
      final repo = ref.read(taskRepositoryProvider);
      final today = LimaTime.todayLima();
      final tasks = await repo.getByDate(today);
      await updateWithTasks(tasks, today);
    } catch (e) {
      debugPrint('HomeWidget updateTodayWidget error: $e');
    }
  }

  /// Escribe los datos de la lista de tareas en el almacenamiento compartido del widget.
  static Future<void> updateWithTasks(List<Task> tasks, String date) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      final pendingTasks = tasks.where((t) => !t.isDone).toList();
      final completedTasks = tasks.where((t) => t.isDone).toList();

      final dayTitle = LimaTime.dayName(date);
      final dateSubtitle = LimaTime.formatShortDay(date);

      final countText = pendingTasks.isEmpty
          ? (completedTasks.isNotEmpty ? 'Al día ✓' : 'Sin tareas')
          : '${pendingTasks.length} ${pendingTasks.length == 1 ? 'pendiente' : 'pendientes'}';

      await HomeWidget.saveWidgetData<String>('day_title', dayTitle);
      await HomeWidget.saveWidgetData<String>('date_subtitle', dateSubtitle);
      await HomeWidget.saveWidgetData<String>('tasks_count', countText);
      await HomeWidget.saveWidgetData<bool>('is_empty', pendingTasks.isEmpty);

      for (int i = 0; i < 4; i++) {
        final key = 'task_${i + 1}';
        if (i < pendingTasks.length) {
          final t = pendingTasks[i];
          final timePrefix = t.timeMinutes != null
              ? '${LimaTime.minutesToHHmm(t.timeMinutes!)} '
              : '';
          await HomeWidget.saveWidgetData<String>(key, '$timePrefix${t.title}');
        } else {
          await HomeWidget.saveWidgetData<String>(key, '');
        }
      }

      final moreCount = pendingTasks.length > 4
          ? '+ ${pendingTasks.length - 4} más...'
          : '';
      await HomeWidget.saveWidgetData<String>('more_count', moreCount);

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('HomeWidget updateWithTasks error: $e');
    }
  }
}
