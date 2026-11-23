import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'wigt_symbol.dart';

/// Widget de logotipo de Wigt con su emblema gráfico único,
/// tipografía geométrica y punto de acento violeta neón.
class WigtLogo extends StatelessWidget {
  const WigtLogo({
    super.key,
    this.fontSize = 24,
    this.badge,
    this.showDot = false,
    this.showSymbol = true,
  });

  final double fontSize;
  final String? badge;
  final bool showDot;
  final bool showSymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Emblema gráfico oficial de Wigt
        if (showSymbol) ...[
          WigtSymbol(size: fontSize * 1.12),
          const SizedBox(width: 10),
        ],

        // Letras WIGT con ShaderMask degradado
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFEDE9FE),
              Color(0xFFDDD6FE),
            ],
          ).createShader(bounds),
          child: Text(
            'WIGT',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              height: 1.0,
            ),
          ),
        ),

        // Punto de acento violeta eléctrico
        if (showDot) ...[
          const SizedBox(width: 3),
          Container(
            width: fontSize * 0.22,
            height: fontSize * 0.22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],

        // Badge opcional (ej: SEMANA, CALENDARIO)
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.outline,
                width: 0.8,
              ),
            ),
            child: Text(
              badge!.toUpperCase(),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: fontSize * 0.38,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

