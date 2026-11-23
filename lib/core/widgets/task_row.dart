import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/dimens.dart';

/// Fila de tarea para listas de Día y Hoy.
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.title,
    this.notes,
    this.timeStr,
    required this.isDone,
    required this.onToggle,
    this.onTap,
    this.onLongPress,
    this.isOverdue = false,
  });

  final String title;
  final String? notes;
  final String? timeStr; // 'HH:mm' o null
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDone ? AppColors.onMuted : AppColors.onBackground;
    final accentColor = isOverdue ? AppColors.warning : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Círculo de completar
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle();
              },
              child: AnimatedContainer(
                duration: AppDimens.animFast,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? accentColor : AppColors.transparent,
                  border: Border.all(
                    color: isDone ? accentColor : AppColors.outline,
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: AppColors.onBackground)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyLarge.copyWith(
                      color: titleColor,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.onMuted,
                    ),
                  ),
                  if (notes != null && notes!.isNotEmpty)
                    Text(
                      notes!,
                      style: AppText.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Hora
            if (timeStr != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  timeStr!,
                  style: AppText.monoSmall.copyWith(
                    color: isDone ? AppColors.onMuted : accentColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
