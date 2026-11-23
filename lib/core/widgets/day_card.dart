import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/dimens.dart';

/// Tarjeta de día para la pantalla Semana con acabado premium,
/// degradado sutil en el día de hoy, tipografía nítida y barras de progreso elegantes.
class DayCard extends StatelessWidget {
  const DayCard({
    super.key,
    required this.dateStr,
    required this.dayLabel,
    required this.dayNumber,
    required this.taskCount,
    required this.completedCount,
    required this.isToday,
    this.onTap,
  });

  final String dateStr;
  final String dayLabel; // 'LUN', 'MAR', etc.
  final String dayNumber; // '24'
  final int taskCount;
  final int completedCount;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = taskCount == 0 ? 0.0 : completedCount / taskCount;
    final isAllDone = taskCount > 0 && completedCount == taskCount;

    return GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: AnimatedContainer(
        duration: AppDimens.animNormal,
        decoration: BoxDecoration(
          // Degradado obsidiana-violeta sofisticado para hoy; obsidiana oscuro para otros días
          gradient: isToday
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF22133D),
                    Color(0xFF151024),
                  ],
                )
              : null,
          color: isToday ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          border: Border.all(
            color: isToday
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.outline,
            width: isToday ? 1.2 : AppDimens.borderWidth,
          ),
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Fecha + Indicador de estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Barra de acento vertical exclusiva para el día de hoy
                if (isToday) ...[
                  Container(
                    width: 3.5,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Nombre del día (LUN, MAR...) en JetBrains Mono
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isToday ? AppColors.primaryLight : AppColors.onMuted,
                  ),
                ),
                const SizedBox(width: 8),

                // Número del día (24) en Space Grotesk
                Text(
                  dayNumber,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground,
                  ),
                ),

                const Spacer(),

                // Chip "HOY" cuando corresponde
                if (isToday) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'HOY',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Indicador de tareas (Conteo o Estado)
                if (taskCount == 0)
                  Text(
                    'Sin pendientes',
                    style: AppText.bodySmall.copyWith(
                      color: AppColors.onMuted.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAllDone
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isAllDone
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.outline,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAllDone) ...[
                          const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          '$completedCount de $taskCount',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isAllDone
                                ? AppColors.success
                                : (isToday ? AppColors.onBackground : AppColors.onMuted),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.onMuted,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barra de progreso estilizada
            WigtProgressBar(
              value: progress,
              isToday: isToday,
              isCompleted: isAllDone,
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra de progreso de Wigt con degradado y esquinas suaves.
class WigtProgressBar extends StatelessWidget {
  const WigtProgressBar({
    super.key,
    required this.value,
    this.isToday = false,
    this.isCompleted = false,
    this.height = 4,
  });

  final double value; // 0.0 – 1.0
  final bool isToday;
  final bool isCompleted;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fillWidth = constraints.maxWidth * value.clamp(0.0, 1.0);

      return Container(
        height: height,
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.onBackground.withValues(alpha: 0.12)
              : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: AppDimens.animNormal,
            width: fillWidth,
            decoration: BoxDecoration(
              gradient: isCompleted
                  ? const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF10B981)],
                    )
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: value > 0
                  ? [
                      BoxShadow(
                        color: (isCompleted ? AppColors.success : AppColors.primary)
                            .withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      );
    });
  }
}
