import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../core/widgets/task_row.dart';
import '../../data/db/providers.dart';
import '../../data/holidays/holiday_providers.dart';
import 'widgets/overdue_section.dart';

/// Pantalla principal de inicio: Hoy + Sección de Atrasados.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = LimaTime.todayLima();
    final todayTasksAsync = ref.watch(tasksByDateProvider(today));
    final overdueTasksAsync = ref.watch(overdueTasksProvider(today));
    final holidayAsync = ref.watch(holidayForDateProvider(today));
    final repo = ref.read(taskRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hoy', style: AppText.headlineLarge),
            Text(
              LimaTime.formatLong(today),
              style: AppText.monoSmall.copyWith(color: AppColors.primaryLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Nuevo pendiente',
            onPressed: () => context.push('/editor?date=$today'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Badge de feriado de hoy si aplica
                  holidayAsync.when(
                    data: (holiday) {
                      if (holiday == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
                      return SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppDimens.screenMarginH, vertical: 6),
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
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  // Sección Atrasados (si existen)
                  overdueTasksAsync.when(
                    data: (overdue) {
                      if (overdue.isEmpty) {
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      return SliverToBoxAdapter(
                        child: OverdueSection(
                          overdueTasks: overdue,
                          today: today,
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  // Lista de pendientes de hoy
                  todayTasksAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                    error: (err, _) => SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error al cargar pendientes: $err',
                          style: AppText.bodyMedium.copyWith(color: AppColors.danger),
                        ),
                      ),
                    ),
                    data: (tasks) {
                      if (tasks.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: AppColors.onMuted.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Sin pendientes hoy',
                                  style: AppText.titleSmall.copyWith(color: AppColors.onMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toca + arriba para agregar uno',
                                  style: AppText.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.screenMarginH,
                          vertical: 8,
                        ),
                        sliver: SliverList.separated(
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
                                  context.push('/editor?taskId=${task.id}&date=$today');
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
