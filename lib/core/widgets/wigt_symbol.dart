import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Emblema gráfico y único de Wigt: el mismo icono de aplicación
/// con prisma geométrico, borde sutil y acabado obsidiana-neón.
class WigtSymbol extends StatelessWidget {
  const WigtSymbol({
    super.key,
    this.size = 28,
    this.showGlow = true,
    this.borderRadius,
  });

  final double size;
  final bool showGlow;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.22);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: size * 0.45,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 0.5),
        child: Image.asset(
          'assets/images/wigt_symbol.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
