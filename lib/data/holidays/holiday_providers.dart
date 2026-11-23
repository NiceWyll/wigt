import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'holiday_model.dart';
import 'holiday_service.dart';

final holidayServiceProvider = Provider<HolidayService>((ref) {
  return HolidayService();
});

/// Provider que carga el mapa de todos los feriados ('yyyy-MM-dd' -> Holiday).
final holidaysMapProvider = FutureProvider<Map<String, Holiday>>((ref) async {
  final service = ref.watch(holidayServiceProvider);
  return service.getHolidaysMap();
});

/// Provider para consultar si un día específico es feriado.
final holidayForDateProvider = FutureProvider.family<Holiday?, String>((ref, date) async {
  final holidaysMap = await ref.watch(holidaysMapProvider.future);
  return holidaysMap[date];
});

