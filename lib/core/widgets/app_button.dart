import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../theme/dimens.dart';

/// Botón principal de Wigt.
/// [onPressed] null → deshabilitado.
/// [variant] controla el estilo.
enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.minWidth,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _colors();
    return SizedBox(
      height: AppDimens.buttonHeight,
      width: minWidth,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        child: InkWell(
          onTap: onPressed == null || isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          child: Container(
            decoration: border != null
                ? BoxDecoration(
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fg,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: fg, size: AppDimens.iconSizeMd),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppText.titleSmall.copyWith(color: fg),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color bg, Color fg, Color? border) _colors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return (
          onPressed == null ? AppColors.surfaceHigh : AppColors.primary,
          onPressed == null ? AppColors.onMuted : AppColors.onBackground,
          null,
        );
      case AppButtonVariant.secondary:
        return (AppColors.surface, AppColors.primaryLight, AppColors.outline);
      case AppButtonVariant.danger:
        return (AppColors.danger.withValues(alpha: 0.15), AppColors.danger, AppColors.danger.withValues(alpha: 0.4));
      case AppButtonVariant.ghost:
        return (AppColors.transparent, AppColors.primaryLight, null);
    }
  }
}
