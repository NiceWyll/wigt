/// Dimensiones y espaciados de Wigt.
/// Rejilla de 8 px.
abstract final class AppDimens {
  // Márgenes laterales
  static const double pagePadding = 20.0;
  static const double screenMarginH = 20.0;

  // Separaciones entre tarjetas
  static const double cardSpacing = 12.0;

  // Esquinas
  static const double radiusCard = 14.0;
  static const double radiusField = 10.0;
  static const double radiusButton = 10.0;
  static const double radiusSmall = 6.0;

  // Áreas táctiles mínimas
  static const double minTapTarget = 48.0;

  // Bordes
  static const double borderWidth = 1.0;

  // Iconos
  static const double iconSizeMd = 20.0;
  static const double iconSizeSm = 16.0;

  // Alturas comunes
  static const double buttonHeight = 52.0;
  static const double fieldHeight = 52.0;
  static const double navBarHeight = 64.0;

  // Ancho máximo de contenido (tablet)
  static const double maxContentWidth = 560.0;

  // Animaciones
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 220);
}
