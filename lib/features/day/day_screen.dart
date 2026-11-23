import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../core/widgets/task_row.dart';
import '../../core/widgets/home_widget_service.dart';
import '../../data/db/app_database.dart';
import '../../data/db/providers.dart';
import '../../data/holidays/holiday_providers.dart';

/// Pantalla de detalle de un día específico.
class DayScreen extends ConsumerWidget {
  const DayScreen({
    super.key,
    required this.date,
  });

  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByDateProvider(date));
    final holidayAsync = ref.watch(holidayForDateProvider(date));
    final repo = ref.read(taskRepositoryProvider);
    final isToday = date == LimaTime.todayLima();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.canPop() ? context.pop() : context.go('/today'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Nuevo pendiente',
            onPressed: () => context.push('/editor?date=$date'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera del día
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMarginH),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    LimaTime.dayName(date),
                    style: AppText.headlineLarge.copyWith(
                      color: isToday ? AppColors.primaryLight : AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    LimaTime.formatShortDay(date),
                    style: AppText.monoMedium.copyWith(color: AppColors.onMuted),
                  ),
                  if (isToday) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text('HOY', style: AppText.labelSmall.copyWith(color: AppColors.primaryLight)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Línea divisoria
            const Divider(color: AppColors.outline, height: 1),
            // Badge de feriado si aplica
            holidayAsync.when(
              data: (holiday) {
                if (holiday == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppDimens.screenMarginH, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration, size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Feriado: ${holiday.name}',
                          style: AppText.bodyMedium.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (holiday.provisional)
                        Text(
                          'Provisional',
                          style: AppText.labelSmall.copyWith(
                            color: AppColors.warning.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Lista de pendientes
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error al cargar pendientes: $err',
                    style: AppText.bodyMedium.copyWith(color: AppColors.danger),
                  ),
                ),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: AppColors.onMuted.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sin pendientes este día',
                            style: AppText.titleSmall.copyWith(color: AppColors.onMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toca + arriba para agregar uno',
                            style: AppText.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.screenMarginH,
                      vertical: 12,
                    ),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: AppColors.outline,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.danger.withValues(alpha: 0.2),
                          child: const Icon(Icons.delete_outline, color: AppColors.danger),
                        ),
                        onDismissed: (_) async {
                          HapticFeedback.lightImpact();
                          await repo.deleteTask(task.id);
                          HomeWidgetService.updateTodayWidget(ref);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${task.title}" eliminado'),
                                action: SnackBarAction(
                                  label: 'Deshacer',
                                  textColor: AppColors.primaryLight,
                                  onPressed: () async {
                                    await repo.createTask(
                                      title: task.title,
                                      notes: task.notes,
                                      date: task.date,
                                      timeMinutes: task.timeMinutes,
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: TaskRow(
                          title: task.title,
                          notes: task.notes,
                          timeStr: task.timeMinutes != null
                              ? LimaTime.minutesToHHmm(task.timeMinutes!)
                              : null,
                          isDone: task.isDone,
                          onToggle: () async {
                            await repo.setDone(task.id, done: !task.isDone);
                          },
                          onTap: () {
                            context.push('/editor?taskId=${task.id}&date=$date');
                          },
                          onLongPress: () {
                            _showTaskOptions(context, ref, task);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, WidgetRef ref, Task task) {
    HapticFeedback.selectionClick();
    final repo = ref.read(taskRepositoryProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusCard)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    task.title,
                    style: AppText.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(color: AppColors.outline),
                ListTile(
                  leading: Icon(
                    task.isDone ? Icons.radio_button_unchecked : Icons.check_circle_outline,
                    color: AppColors.primaryLight,
                  ),
                  title: Text(
                    task.isDone ? 'Marcar como pendiente' : 'Marcar como completada',
                    style: AppText.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    repo.setDone(task.id, done: !task.isDone);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  title: Text('Editar pendiente', style: AppText.bodyMedium),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/editor?taskId=${task.id}&date=${task.date}');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                  title: const Text(
                    'Eliminar pendiente',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await repo.deleteTask(task.id);
                    HomeWidgetService.updateTodayWidget(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${task.title}" eliminado'),
                          action: SnackBarAction(
                            label: 'Deshacer',
                            textColor: AppColors.primaryLight,
                            onPressed: () async {
                              await repo.createTask(
                                title: task.title,
                                notes: task.notes,
                                date: task.date,
                                timeMinutes: task.timeMinutes,
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
