import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/dimens.dart';
import '../../../core/time/lima_time.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/providers.dart';

/// Sección que muestra los pendientes atrasados con borde ámbar y acciones rápidas.
class OverdueSection extends ConsumerWidget {
  const OverdueSection({
    super.key,
    required this.overdueTasks,
    required this.today,
  });

  final List<Task> overdueTasks;
  final String today;

  Future<void> _rescheduleToToday(WidgetRef ref, String taskId) async {
    HapticFeedback.lightImpact();
    await ref.read(taskRepositoryProvider).reschedule(taskId, today);
  }

  Future<void> _chooseAnotherDay(BuildContext context, WidgetRef ref, Task task) async {
    final current = DateTime.tryParse(task.date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'PE'),
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

    if (picked != null) {
      final newDate = LimaTime.formatDate(picked);
      await ref.read(taskRepositoryProvider).reschedule(task.id, newDate);
    }
  }

  Future<void> _confirmRescheduleAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: const BorderSide(color: AppColors.outline),
        ),
        title: Text('Pasar todos a hoy', style: AppText.titleLarge),
        content: Text(
          '¿Mover los ${overdueTasks.length} pendientes atrasados a la lista de hoy?',
          style: AppText.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: AppText.bodyMedium.copyWith(color: AppColors.onMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Pasar a hoy', style: AppText.bodyMedium.copyWith(color: AppColors.warning)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref.read(taskRepositoryProvider).rescheduleAllOverdue(today);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (overdueTasks.isEmpty) return const SizedBox.shrink();

    final repo = ref.read(taskRepositoryProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenMarginH,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con contador y botón "Pasar todos"
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Atrasados',
                  style: AppText.titleSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${overdueTasks.length}',
                    style: AppText.monoSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _confirmRescheduleAll(context, ref),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    'Pasar todos a hoy',
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.outline, height: 1),
          // Lista de tareas atrasadas
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: overdueTasks.length,
            separatorBuilder: (_, __) => const Divider(color: AppColors.outline, height: 1),
            itemBuilder: (context, index) {
              final task = overdueTasks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Círculo para marcar hecho
                    GestureDetector(
                      key: ValueKey('overdue_check_${task.id}'),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await repo.setDone(task.id, done: true);
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.warning, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Título y fecha original
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/editor?taskId=${task.id}&date=${task.date}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: AppText.bodyMedium.copyWith(color: AppColors.onBackground),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Era para el ${LimaTime.formatShortDay(task.date)}',
                              style: AppText.monoSmall.copyWith(
                                color: AppColors.warning.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Acción: Pasar a hoy
                    IconButton(
                      icon: const Icon(Icons.today, size: 20, color: AppColors.warning),
                      tooltip: 'Pasar a hoy',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _rescheduleToToday(ref, task.id),
                    ),
                    // Acción: Elegir otro día
                    IconButton(
                      icon: const Icon(Icons.edit_calendar, size: 20, color: AppColors.onMuted),
                      tooltip: 'Elegir otro día',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _chooseAnotherDay(context, ref, task),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
