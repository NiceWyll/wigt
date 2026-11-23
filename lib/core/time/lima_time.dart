import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Funciones de tiempo para la zona horaria America/Lima.
/// Toda la lógica de fechas de la app pasa por aquí.
class LimaTime {
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
  }

  static tz.Location get _lima {
    init();
    return tz.getLocation('America/Lima');
  }

  /// Fecha de hoy en Lima como 'yyyy-MM-dd'.
  static String todayLima() {
    final now = tz.TZDateTime.now(_lima);
    return _format(now.year, now.month, now.day);
  }

  /// TZDateTime actual en Lima.
  static tz.TZDateTime nowLima() => tz.TZDateTime.now(_lima);

  /// Primer día (lunes) de la semana que contiene [dateStr].
  /// [dateStr] formato 'yyyy-MM-dd'.
  static String startOfWeek(String dateStr) {
    final d = _parseDate(dateStr);
    // DateTime weekday: 1=lunes, 7=domingo
    final diff = d.weekday - DateTime.monday;
    final monday = d.subtract(Duration(days: diff));
    return _format(monday.year, monday.month, monday.day);
  }

  /// Devuelve los 7 días (lun–dom) de la semana que contiene [dateStr].
  /// Retorna lista de strings 'yyyy-MM-dd' de lunes a domingo.
  static List<String> weekDays(String dateStr) {
    final monday = _parseDate(startOfWeek(dateStr));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return _format(d.year, d.month, d.day);
    });
  }

  /// Devuelve el primer día del mes dado.
  static String firstDayOfMonth(int year, int month) =>
      _format(year, month, 1);

  /// Devuelve el último día del mes dado.
  static String lastDayOfMonth(int year, int month) {
    final d = DateTime(year, month + 1, 0);
    return _format(d.year, d.month, d.day);
  }

  /// Convierte minutos desde medianoche a 'HH:mm'.
  static String minutesToHHmm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  /// Parsea 'HH:mm' a minutos desde medianoche.
  static int hhmmToMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Compara dos fechas 'yyyy-MM-dd'. Retorna negativo, 0 o positivo.
  static int compareDate(String a, String b) => a.compareTo(b);

  /// True si [dateStr] es anterior a hoy en Lima.
  static bool isOverdue(String dateStr) =>
      compareDate(dateStr, todayLima()) < 0;

  /// True si [dateStr] es hoy en Lima.
  static bool isToday(String dateStr) => dateStr == todayLima();

  static DateTime _parseDate(String s) {
    final parts = s.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static String _format(int y, int m, int d) =>
      '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  /// Formatea un DateTime a 'yyyy-MM-dd'.
  static String formatDate(DateTime d) => _format(d.year, d.month, d.day);

  /// Formato largo: 'lunes, 24 de noviembre'
  static String formatFullDate(String dateStr) => formatLong(dateStr);

  /// Formato largo: 'lunes, 24 de noviembre'
  /// Requiere que intl ya esté inicializado con es_PE.
  static String formatLong(String dateStr) {
    final d = _parseDate(dateStr);
    final dayNames = [
      'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
    ];
    final monthNames = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${dayNames[d.weekday - 1]}, ${d.day} de ${monthNames[d.month]}';
  }

  /// Abreviatura del día (1=Lunes a 7=Domingo), ej: 'LUN'
  static String shortDayName(int weekday) {
    const dayAbbr = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return dayAbbr[weekday - 1];
  }

  /// Formato corto día: 'LUN 24'
  static String formatShortDay(String dateStr) {
    final d = _parseDate(dateStr);
    const dayAbbr = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return '${dayAbbr[d.weekday - 1]} ${d.day}';
  }

  /// Formato 'dd MMM' en español, ej: '24 NOV'
  static String formatDayMonth(String dateStr) {
    final d = _parseDate(dateStr);
    const months = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
    ];
    return '${d.day} ${months[d.month]}';
  }

  /// Nombre del día de la semana, ej: 'Lunes'
  static String dayName(String dateStr) {
    final d = _parseDate(dateStr);
    const names = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return names[d.weekday - 1];
  }

  /// Nombre del mes en español, ej: 'noviembre'
  static String monthName(int month) {
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return months[month];
  }

  /// Mes y año formateado, ej: 'Noviembre 2026'
  static String formatMonthYear(int year, int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[month]} $year';
  }

  /// Extrae año, mes y día de un string 'yyyy-MM-dd'.
  static (int year, int month, int day) parseComponents(String dateStr) {
    final d = _parseDate(dateStr);
    return (d.year, d.month, d.day);
  }

  /// Suma [days] días a una fecha.
  static String addDays(String dateStr, int days) {
    final d = _parseDate(dateStr).add(Duration(days: days));
    return _format(d.year, d.month, d.day);
  }

  /// TZDateTime para un día y hora (minutos) en Lima.
  static tz.TZDateTime tzDateTime(String dateStr, int timeMinutes) {
    final d = _parseDate(dateStr);
    return tz.TZDateTime(
      _lima, d.year, d.month, d.day, timeMinutes ~/ 60, timeMinutes % 60,
    );
  }
}
