import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/providers.dart';
import '../../data/settings/settings_providers.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  return service;
});

/// Función de conveniencia para reprogramar la ventana de notificaciones.
final rescheduleNotificationsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final service = ref.read(notificationServiceProvider);
    final repo = ref.read(taskRepositoryProvider);
    final settings = ref.read(settingsProvider);
    await service.scheduleWindow(repo: repo, settings: settings);
  };
});

