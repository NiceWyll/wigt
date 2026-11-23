import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto de Wigt.
/// - Títulos: SpaceGrotesk
/// - Texto general: Inter
/// - Fechas y horas: JetBrainsMono
abstract final class AppText {
  // ── Títulos (SpaceGrotesk) ───────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headlineLarge = displayLarge;

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle headlineMedium = displayMedium;

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
    height: 1.4,
  );

  // ── Cuerpo (Inter) ───────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onMuted,
    height: 1.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.onMuted,
    letterSpacing: 0.8,
    height: 1.4,
  );

  // ── Mono (JetBrainsMono) — fechas, horas, números ───────────────────────
  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.onBackground,
    height: 1.3,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onBackground,
    height: 1.4,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onMuted,
    height: 1.4,
  );

  // ── Etiquetas de día (ej: LUN, MAR) ─────────────────────────────────────
  static const TextStyle dayLabel = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.onMuted,
    letterSpacing: 1.0,
    height: 1.2,
  );
}
