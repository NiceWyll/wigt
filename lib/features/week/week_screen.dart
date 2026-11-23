import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../core/widgets/day_card.dart';
import '../../core/widgets/wigt_logo.dart';
import '../../data/db/app_database.dart';
import '../../data/db/providers.dart';
import '../today/widgets/overdue_section.dart';

/// Pantalla Semana: 7 tarjetas LUN-DOM, navegación entre semanas y resumen.
class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  late String _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = LimaTime.startOfWeek(LimaTime.todayLima());
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

    final tasksAsync = ref.watch(tasksBetweenProvider((start: weekStart, end: weekEnd)));
    final overdueAsync = ref.watch(overdueTasksProvider(today));
    final overdueTasks = isCurrentWeek ? (overdueAsync.valueOrNull ?? []) : <Task>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: AppDimens.screenMarginH,
        title: const WigtLogo(badge: 'Semana', fontSize: 24),
        actions: [
          if (!isCurrentWeek)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: _goToCurrentWeek,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.today_rounded, size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Text(
                        'Hoy',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.screenMarginH),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline, width: 0.8),
              ),
              child: IconButton(
                icon: const Icon(Icons.insights_rounded, size: 19, color: AppColors.primaryLight),
                tooltip: 'Revisión semanal',
                visualDensity: VisualDensity.compact,
                onPressed: () => context.push('/review/$_currentWeekStart'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de semana elegante con flechas y fecha nítida
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenMarginH,
                vertical: 6,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.outline, width: 0.8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: AppColors.onBackground),
                      tooltip: 'Semana anterior',
                      visualDensity: VisualDensity.compact,
                      onPressed: _previousWeek,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatWeekRange(weekDays),
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppColors.onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: AppColors.onBackground),
                      tooltip: 'Semana siguiente',
                      visualDensity: VisualDensity.compact,
                      onPressed: _nextWeek,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 7 Tarjetas de día (LUN a DOM)
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Error: $err',
                    style: AppText.bodyMedium.copyWith(color: AppColors.danger),
                  ),
                ),
                data: (tasks) {
                  // Contadores por día
                  final totalByDay = <String, int>{};
                  final completedByDay = <String, int>{};

                  for (final t in tasks) {
                    totalByDay[t.date] = (totalByDay[t.date] ?? 0) + 1;
                    if (t.isDone) {
                      completedByDay[t.date] = (completedByDay[t.date] ?? 0) + 1;
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.screenMarginH,
                      8,
                      AppDimens.screenMarginH,
                      20,
                    ),
                    child: Column(
                      children: [
                        if (overdueTasks.isNotEmpty) ...[
                          OverdueSection(
                            overdueTasks: overdueTasks,
                            today: today,
                          ),
                          const SizedBox(height: 12),
                        ],
                        ...List.generate(7, (index) {
                        final dayDate = weekDays[index];
                        final isDayToday = dayDate == today;
                        final short = LimaTime.formatShortDay(dayDate);
                        final parts = short.split(' ');

                        final total = totalByDay[dayDate] ?? 0;
                        final completed = completedByDay[dayDate] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.cardSpacing),
                          child: DayCard(
                            dateStr: dayDate,
                            dayLabel: parts[0],
                            dayNumber: parts.length > 1 ? parts[1] : '',
                            taskCount: total,
                            completedCount: completed,
                            isToday: isDayToday,
                            onTap: () => context.push('/day/$dayDate'),
                          ),
                        );
                      }),
                    ],
                  ),
                );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
