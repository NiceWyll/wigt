import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications/notification_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../data/settings/settings_providers.dart';

/// Pantalla de Ajustes de Wigt: notificaciones, horas y permisos.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _permissionStatusMsg;

  Future<void> _selectMorningTime(int currentMinutes) async {
    final initial = TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onBackground,
              surface: AppColors.surface,
              onSurface: AppColors.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final newMinutes = picked.hour * 60 + picked.minute;
      await ref.read(settingsProvider.notifier).setMorningSummaryMinutes(newMinutes);
      await ref.read(rescheduleNotificationsProvider)();
    }
  }

  Future<void> _selectWeeklyTime(int currentMinutes) async {
    final initial = TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onBackground,
              surface: AppColors.surface,
              onSurface: AppColors.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final newMinutes = picked.hour * 60 + picked.minute;
      await ref.read(settingsProvider.notifier).setWeeklyReviewMinutes(newMinutes);
      await ref.read(rescheduleNotificationsProvider)();
    }
  }

  Future<void> _requestNotificationPermission() async {
    HapticFeedback.lightImpact();
    final service = ref.read(notificationServiceProvider);
    final granted = await service.requestPermissions();

    if (mounted) {
      setState(() {
        _permissionStatusMsg = granted
            ? 'Permiso de notificaciones activado correctamente.'
            : 'Las notificaciones están desactivadas en los ajustes del teléfono.';
      });
      if (granted) {
        await ref.read(rescheduleNotificationsProvider)();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Ajustes', style: AppText.headlineLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenMarginH,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección: Resumen de la mañana
              Text('RESUMEN DE LA MAÑANA', style: AppText.labelSmall),
              const SizedBox(height: 8),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  side: const BorderSide(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: settings.morningSummaryEnabled,
                      activeTrackColor: AppColors.primary,
                      title: Text('Activar resumen diario', style: AppText.bodyLarge),
                      subtitle: Text(
                        'Recibe tus pendientes del día cada mañana',
                        style: AppText.bodySmall,
                      ),
                      onChanged: (val) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .setMorningSummaryEnabled(val);
                        await ref.read(rescheduleNotificationsProvider)();
                      },
                    ),
                    if (settings.morningSummaryEnabled) ...[
                      const Divider(color: AppColors.outline, height: 1),
                      ListTile(
                        title: Text('Hora del resumen', style: AppText.bodyMedium),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            LimaTime.minutesToHHmm(settings.morningSummaryMinutes),
                            style: AppText.monoMedium.copyWith(color: AppColors.primaryLight),
                          ),
                        ),
                        onTap: () => _selectMorningTime(settings.morningSummaryMinutes),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección: Revisión semanal
              Text('REVISIÓN SEMANAL', style: AppText.labelSmall),
              const SizedBox(height: 8),
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  side: const BorderSide(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: settings.weeklyReviewEnabled,
                      activeTrackColor: AppColors.primary,
                      title: Text('Aviso los domingos', style: AppText.bodyLarge),
                      subtitle: Text(
                        'Resumen de logros y porcentaje completado',
                        style: AppText.bodySmall,
                      ),
                      onChanged: (val) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .setWeeklyReviewEnabled(val);
                        await ref.read(rescheduleNotificationsProvider)();
                      },
                    ),
                    if (settings.weeklyReviewEnabled) ...[
                      const Divider(color: AppColors.outline, height: 1),
                      ListTile(
                        title: Text('Hora del aviso', style: AppText.bodyMedium),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            LimaTime.minutesToHHmm(settings.weeklyReviewMinutes),
                            style: AppText.monoMedium.copyWith(color: AppColors.primaryLight),
                          ),
                        ),
                        onTap: () => _selectWeeklyTime(settings.weeklyReviewMinutes),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección: Permisos y estado del sistema
              Text('NOTIFICACIONES Y PERMISOS', style: AppText.labelSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Las notificaciones se programan en tu teléfono en horario de Perú (America/Lima). Funcionan sin conexión a internet y sin servidores externos.',
                      style: AppText.bodyMedium.copyWith(color: AppColors.onMuted),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        side: const BorderSide(color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                        ),
                      ),
                      onPressed: _requestNotificationPermission,
                      icon: const Icon(Icons.notifications_active_outlined, size: 18),
                      label: Text('Verificar permisos de notificación', style: AppText.bodyMedium),
                    ),
                    if (_permissionStatusMsg != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _permissionStatusMsg!,
                        style: AppText.bodySmall.copyWith(
                          color: _permissionStatusMsg!.contains('activado')
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info de la app
              Center(
                child: Column(
                  children: [
                    Text(
                      'Wigt 1.0.0',
                      style: AppText.monoSmall.copyWith(color: AppColors.onMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zona horaria: America/Lima (UTC-5)',
                      style: AppText.bodySmall.copyWith(color: AppColors.onMuted.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
