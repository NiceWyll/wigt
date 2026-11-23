import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/dimens.dart';
import '../../core/time/lima_time.dart';
import '../../data/db/providers.dart';
import '../../data/holidays/holiday_model.dart';
import '../../data/holidays/holiday_providers.dart';

/// Pantalla Calendario mensual con feriados de Perú y puntos de tareas.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late int _displayYear;
  late int _displayMonth;
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = LimaTime.todayLima();
    final parts = today.split('-');
    _displayYear = int.parse(parts[0]);
    _displayMonth = int.parse(parts[1]);
    _selectedDate = today;
  }

  void _previousMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_displayMonth == 1) {
        _displayMonth = 12;
        _displayYear--;
      } else {
        _displayMonth--;
      }
    });
  }

  void _nextMonth() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_displayMonth == 12) {
        _displayMonth = 1;
        _displayYear++;
      } else {
        _displayMonth++;
      }
    });
  }

  void _goToCurrentMonth() {
    HapticFeedback.lightImpact();
    final today = LimaTime.todayLima();
    final parts = today.split('-');
    setState(() {
      _displayYear = int.parse(parts[0]);
      _displayMonth = int.parse(parts[1]);
      _selectedDate = today;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = LimaTime.todayLima();
    final todayParts = today.split('-');
    final isCurrentMonth =
        _displayYear == int.parse(todayParts[0]) &&
        _displayMonth == int.parse(todayParts[1]);

    final firstDayStr = LimaTime.firstDayOfMonth(_displayYear, _displayMonth);
    final lastDayStr = LimaTime.lastDayOfMonth(_displayYear, _displayMonth);

    // Días y tareas del mes
    final tasksAsync = ref.watch(
      tasksBetweenProvider((start: firstDayStr, end: lastDayStr)),
    );
    final holidaysAsync = ref.watch(holidaysMapProvider);

    final firstDate = DateTime(_displayYear, _displayMonth, 1);
    final daysInMonth = DateTime(_displayYear, _displayMonth + 1, 0).day;
    // Lunes = 1, Domingo = 7. Offset de celdas vacías al inicio:
    final startOffset = firstDate.weekday - 1;
    final totalCells = ((startOffset + daysInMonth + 6) ~/ 7) * 7;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Calendario', style: AppText.headlineLarge),
        actions: [
          if (!isCurrentMonth)
            TextButton.icon(
              onPressed: _goToCurrentMonth,
              icon: const Icon(Icons.today, size: 16, color: AppColors.primaryLight),
              label: Text(
                'Hoy',
                style: AppText.bodySmall.copyWith(color: AppColors.primaryLight),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenMarginH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de mes con flechas
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.onBackground),
                      tooltip: 'Mes anterior',
                      visualDensity: VisualDensity.compact,
                      onPressed: _previousMonth,
                    ),
                    Expanded(
                      child: Text(
                        LimaTime.formatMonthYear(_displayYear, _displayMonth),
                        style: AppText.titleMedium.copyWith(color: AppColors.onBackground),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.onBackground),
                      tooltip: 'Mes siguiente',
                      visualDensity: VisualDensity.compact,
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Cabecera de días de la semana (L M X J V S D)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _WeekdayLabel('L'),
                  _WeekdayLabel('M'),
                  _WeekdayLabel('X'),
                  _WeekdayLabel('J'),
                  _WeekdayLabel('V'),
                  _WeekdayLabel('S'),
                  _WeekdayLabel('D'),
                ],
              ),

              const SizedBox(height: 6),

              // Cuadrícula mensual
              tasksAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Error: $err', style: AppText.bodySmall),
                ),
                data: (tasks) {
                  final taskDays = <String>{for (final t in tasks) t.date};
                  final holidaysMap = holidaysAsync.value ?? {};

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalCells,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final dayNum = index - startOffset + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const SizedBox.shrink();
                      }

                      final dayDate =
                          '$_displayYear-${_displayMonth.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                      final isDayToday = dayDate == today;
                      final isSelected = dayDate == _selectedDate;
                      final hasTasks = taskDays.contains(dayDate);
                      final holiday = holidaysMap[dayDate];

                      return _CalendarDayCell(
                        dayNumber: dayNum,
                        dateStr: dayDate,
                        isToday: isDayToday,
                        isSelected: isSelected,
                        hasTasks: hasTasks,
                        holiday: holiday,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDate = dayDate);
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Tarjeta de detalle del día seleccionado
              _SelectedDayCard(
                dateStr: _selectedDate,
                today: today,
                holiday: holidaysAsync.value?[_selectedDate],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppText.dayLabel.copyWith(
          color: label == 'S' || label == 'D' ? AppColors.onMuted : AppColors.primaryLight,
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.dayNumber,
    required this.dateStr,
    required this.isToday,
    required this.isSelected,
    required this.hasTasks,
    required this.holiday,
    required this.onTap,
  });

  final int dayNumber;
  final String dateStr;
  final bool isToday;
  final bool isSelected;
  final bool hasTasks;
  final Holiday? holiday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;

    if (isSelected) {
      decoration = BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.primary, width: 1.5),
      );
    } else {
      decoration = BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        border: Border.all(color: AppColors.outline, width: 0.8),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNumber',
              style: AppText.monoMedium.copyWith(
                fontWeight: isToday || isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isToday
                    ? AppColors.primaryLight
                    : (holiday != null ? AppColors.warning : AppColors.onBackground),
              ),
            ),
            const SizedBox(height: 3),
            // Puntos de marca (morado para tareas, ámbar para feriado)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTasks)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (holiday != null)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDayCard extends ConsumerWidget {
  const _SelectedDayCard({
    required this.dateStr,
    required this.today,
    this.holiday,
  });

  final String dateStr;
  final String today;
  final Holiday? holiday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByDateProvider(dateStr));
    final isToday = dateStr == today;

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LimaTime.formatFullDate(dateStr),
                      style: AppText.titleSmall.copyWith(
                        color: isToday ? AppColors.primaryLight : AppColors.onBackground,
                      ),
                    ),
                    Text(dateStr, style: AppText.monoSmall.copyWith(color: AppColors.onMuted)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: AppColors.primaryLight),
                tooltip: 'Abrir día',
                onPressed: () => context.push('/day/$dateStr'),
              ),
            ],
          ),

          // Marca y nombre de feriado (si aplica)
          if (holiday != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Feriado: ${holiday!.name}',
                      style: AppText.bodyMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (holiday!.provisional)
                    Text(
                      'Provisional',
                      style: AppText.labelSmall.copyWith(
                        color: AppColors.warning.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: AppColors.outline, height: 1),
          const SizedBox(height: 10),

          // Resumen de tareas de ese día
          tasksAsync.when(
            loading: () => const SizedBox(
              height: 24,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            ),
            error: (err, _) => Text('Error: $err', style: AppText.bodySmall),
            data: (tasks) {
              if (tasks.isEmpty) {
                return Row(
                  children: [
                    Text('Sin pendientes registrados', style: AppText.bodySmall),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/editor?date=$dateStr'),
                      child: Text('Agregar', style: AppText.bodySmall.copyWith(color: AppColors.primaryLight)),
                    ),
                  ],
                );
              }
              final done = tasks.where((t) => t.isDone).length;
              return Row(
                children: [
                  Text(
                    '$done de ${tasks.length} pendientes completados',
                    style: AppText.bodySmall.copyWith(color: AppColors.onBackground),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/day/$dateStr'),
                    child: Text('Ver lista', style: AppText.bodySmall.copyWith(color: AppColors.primaryLight)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

