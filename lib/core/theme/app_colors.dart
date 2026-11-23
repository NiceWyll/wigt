import 'package:flutter/material.dart';

/// Paleta de colores de Wigt — tema oscuro.
/// Todos los colores de la app viven aquí.
abstract final class AppColors {
  // Fondos
  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF14141B);
  static const Color surfaceHigh = Color(0xFF1C1C26);
  static const Color outline = Color(0xFF2A2A38);

  // Primario (morado)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDeep = Color(0xFF6D28D9);

  // Texto
  static const Color onBackground = Color(0xFFF4F4F8);
  static const Color onMuted = Color(0xFF9A9AB0);

  // Estados
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);

  // Transparentes útiles
  static const Color transparent = Colors.transparent;
}
