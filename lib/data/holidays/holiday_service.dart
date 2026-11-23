import 'dart:convert';
import 'package:flutter/services.dart';
import 'holiday_model.dart';

/// Servicio para cargar y consultar feriados oficiales de Perú desde assets/holidays/holidays_pe.json.
class HolidayService {
  HolidayService({this.assetPath = 'assets/holidays/holidays_pe.json'});

  final String assetPath;
  List<Holiday>? _cachedList;
  Map<String, Holiday>? _cachedMap;

  Future<List<Holiday>> loadHolidays() async {
    if (_cachedList != null) return _cachedList!;

    final jsonString = await rootBundle.loadString(assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = (data['holidays'] as List<dynamic>)
        .map((e) => Holiday.fromJson(e as Map<String, dynamic>))
        .toList();

    _cachedList = list;
    _cachedMap = {for (final h in list) h.date: h};
    return list;
  }

  Future<Map<String, Holiday>> getHolidaysMap() async {
    if (_cachedMap != null) return _cachedMap!;
    await loadHolidays();
    return _cachedMap!;
  }

  Future<Holiday?> getHolidayForDate(String date) async {
    final map = await getHolidaysMap();
    return map[date];
  }
}
