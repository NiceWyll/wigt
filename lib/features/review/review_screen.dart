import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../core/widgets/day_card.dart';
import '../../data/db/providers.dart';
import '../../data/db/task_dao.dart';

/// Pantalla de Revisión Semanal (/review/:weekStart)
/// Muestra estadísticas de la semana lunes-domingo:
/// - Total y completados con porcentaje
/// - Barras de avance por día (LUN-DOM)
/// - Cantidad de tareas reprogramadas (rescheduledCount > 0)
/// - Cantidad de tareas sin hacer
/// - Comparación con la semana anterior
/// - Navegación entre semanas pasadas y futuras
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({
    super.key,
    required this.weekStart,
  });

  final String weekStart;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late String _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = widget.weekStart;
  }

  void _previousWeek() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentWeekStart = LimaTime.addDays(_currentWeekStart, -7);
    });
  }

  void _nextWeek() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentWeekStart = LimaTime.addDays(_currentWeekStart, 7);
    });
  }

  void _goToCurrentWeek() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentWeekStart = LimaTime.startOfWeek(LimaTime.todayLima());
    });
  }

  String _formatWeekRange(List<String> days) {
    final first = days.first;
    final last = days.last;
    final firstParts = first.split('-');
    final lastParts = last.split('-');

    final startDay = int.parse(firstParts[2]);
    final endDay = int.parse(lastParts[2]);
    final monthName = LimaTime.monthName(int.parse(lastParts[1]));

    return '$startDay al $endDay de $monthName';
  }

  @override
  Widget build(BuildContext context) {
    final today = LimaTime.todayLima();
    final thisWeekStart = LimaTime.startOfWeek(today);
    final isCurrentWeek = _currentWeekStart == thisWeekStart;

    final weekDays = LimaTime.weekDays(_currentWeekStart);
    final weekStart = weekDays.first;
    final weekEnd = weekDays.last;

    // Rango de la semana anterior para comparación
    final prevWeekStart = LimaTime.addDays(weekStart, -7);
    final prevWeekEnd = LimaTime.addDays(weekStart, -1);

    final currentTasksAsync =
        ref.watch(tasksBetweenProvider((start: weekStart, end: weekEnd)));
    final prevTasksAsync =
        ref.watch(tasksBetweenProvider((start: prevWeekStart, end: prevWeekEnd)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => context.pop(),
        ),
        title: Text('Revisión semanal', style: AppText.headlineLarge),
        actions: [
          if (!isCurrentWeek)
            TextButton.icon(
              onPressed: _goToCurrentWeek,
              icon: const Icon(Icons.today, size: 16, color: AppColors.primaryLight),
              label: Text(
                'Esta semana',
                style: AppText.bodySmall.copyWith(color: AppColors.primaryLight),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
            child: currentTasksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(
                child: Text('Error al cargar datos: $err', style: AppText.bodyMedium),
              ),
              data: (currentTasks) {
                final stats = WeekStats.fromTasks(currentTasks);
                final prevTasks = prevTasksAsync.valueOrNull ?? [];
                final prevStats = WeekStats.fromTasks(prevTasks);

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenMarginH,
                    vertical: 12,
                  ),
                  children: [
                    // Selector de semana
                    _buildWeekNavigator(weekDays),
                    const SizedBox(height: 16),

                    if (stats.total == 0)
                      _buildEmptyState()
                    else ...[
                      // Resumen principal (Hero)
                      _buildHeroCard(stats),
                      const SizedBox(height: 12),

                      // Comparación con la semana anterior
                      _buildComparisonCard(stats, prevStats),
                      const SizedBox(height: 12),

                      // Tarjetas de métricas secundarias
                      _buildMetricsRow(stats),
                      const SizedBox(height: 20),

                      // Barras por día (LUN a DOM)
                      _buildDailyBreakdown(weekDays, stats),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigator(List<String> weekDays) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.onBackground),
            tooltip: 'Semana anterior',
            onPressed: _previousWeek,
          ),
          Expanded(
            child: Text(
              _formatWeekRange(weekDays),
              textAlign: TextAlign.center,
              style: AppText.headlineMedium.copyWith(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.onBackground),
            tooltip: 'Semana siguiente',
            onPressed: _nextWeek,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available,
            size: 48,
            color: AppColors.onMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin pendientes esta semana',
            style: AppText.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No hay tareas registradas entre el ${_formatWeekRange(LimaTime.weekDays(_currentWeekStart))}.',
            style: AppText.bodyMedium.copyWith(color: AppColors.onMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(WeekStats stats) {
    final percentage = (stats.completionRate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$percentage%',
                style: AppText.headlineLarge.copyWith(
                  fontSize: 40,
                  color: AppColors.primaryLight,
                ),
              ),
              Text(
                '${stats.completed} de ${stats.total} completados',
                style: AppText.monoMedium.copyWith(color: AppColors.onBackground),
              ),
            ],
          ),
          const SizedBox(height: 14),
          WigtProgressBar(
            value: stats.completionRate,
            height: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(WeekStats current, WeekStats previous) {
    final diff = current.completed - previous.completed;

    IconData icon;
    Color color;
    String text;

    if (previous.total == 0) {
      icon = Icons.info_outline;
      color = AppColors.onMuted;
      text = 'Semana anterior sin tareas registradas';
    } else if (diff > 0) {
      icon = Icons.trending_up;
      color = AppColors.success;
      text = '+$diff completados más que la semana anterior';
    } else if (diff < 0) {
      icon = Icons.trending_down;
      color = AppColors.onMuted;
      text = '${diff.abs()} menos completados que la semana anterior';
    } else {
      icon = Icons.trending_flat;
      color = AppColors.primaryLight;
      text = 'Mismo número de completados que la semana anterior';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppText.bodyMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(WeekStats stats) {
    return Row(
      children: [
        // Sin hacer
        Expanded(
          child: Container(
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
                  '${stats.remaining}',
                  style: AppText.monoLarge.copyWith(
                    color: stats.remaining > 0 ? AppColors.onBackground : AppColors.onMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sin hacer',
                  style: AppText.bodySmall.copyWith(color: AppColors.onMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Reprogramados
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              border: Border.all(
                color: stats.rescheduled > 0
                    ? AppColors.warning.withValues(alpha: 0.5)
                    : AppColors.outline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.rescheduled}',
                  style: AppText.monoLarge.copyWith(
                    color: stats.rescheduled > 0
                        ? AppColors.warning
                        : AppColors.onMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reprogramados',
                  style: AppText.bodySmall.copyWith(color: AppColors.onMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyBreakdown(List<String> weekDays, WeekStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Avance por día', style: AppText.headlineMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekDays.map((dateStr) {
              final parts = dateStr.split('-');
              final dayNumber = parts[2];
              final date = DateTime.parse(dateStr);
              final dayLabel = LimaTime.shortDayName(date.weekday);

              final dayTotal = stats.totalByDay[dateStr] ?? 0;
              final dayCompleted = stats.completedByDay[dateStr] ?? 0;
              final dayProgress = dayTotal == 0 ? 0.0 : dayCompleted / dayTotal;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push('/day/$dateStr');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      // Barra vertical
                      Container(
                        height: 70,
                        width: 18,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline, width: 0.5),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: dayProgress.clamp(0.0, 1.0),
                            widthFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: dayProgress == 1.0
                                    ? AppColors.success
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Conteo
                      Text(
                        dayTotal == 0 ? '-' : '$dayCompleted/$dayTotal',
                        style: AppText.monoSmall.copyWith(
                          fontSize: 10,
                          color: dayTotal > 0 ? AppColors.onBackground : AppColors.onMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nombre del día
                      Text(
                        dayLabel,
                        style: AppText.dayLabel.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      // Número del día
                      Text(
                        dayNumber,
                        style: AppText.monoSmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

