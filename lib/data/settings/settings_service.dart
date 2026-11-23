import 'package:shared_preferences/shared_preferences.dart';

/// Estado de configuración de la app.
class SettingsState {
  const SettingsState({
    this.morningSummaryEnabled = true,
    this.morningSummaryMinutes = 450, // 07:30 (7 * 60 + 30)
    this.weeklyReviewEnabled = true,
    this.weeklyReviewMinutes = 1200, // 20:00 (20 * 60)
  });

  final bool morningSummaryEnabled;
  final int morningSummaryMinutes;
  final bool weeklyReviewEnabled;
  final int weeklyReviewMinutes;

  SettingsState copyWith({
    bool? morningSummaryEnabled,
    int? morningSummaryMinutes,
    bool? weeklyReviewEnabled,
    int? weeklyReviewMinutes,
  }) {
    return SettingsState(
      morningSummaryEnabled: morningSummaryEnabled ?? this.morningSummaryEnabled,
      morningSummaryMinutes: morningSummaryMinutes ?? this.morningSummaryMinutes,
      weeklyReviewEnabled: weeklyReviewEnabled ?? this.weeklyReviewEnabled,
      weeklyReviewMinutes: weeklyReviewMinutes ?? this.weeklyReviewMinutes,
    );
  }
}

/// Servicio de almacenamiento local de ajustes usando shared_preferences.
class SettingsService {
  static const _kMorningEnabled = 'morning_summary_enabled';
  static const _kMorningMinutes = 'morning_summary_minutes';
  static const _kWeeklyEnabled = 'weekly_review_enabled';
  static const _kWeeklyMinutes = 'weekly_review_minutes';

  Future<SettingsState> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsState(
      morningSummaryEnabled: prefs.getBool(_kMorningEnabled) ?? true,
      morningSummaryMinutes: prefs.getInt(_kMorningMinutes) ?? 450,
      weeklyReviewEnabled: prefs.getBool(_kWeeklyEnabled) ?? true,
      weeklyReviewMinutes: prefs.getInt(_kWeeklyMinutes) ?? 1200,
    );
  }

  Future<void> saveSettings(SettingsState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMorningEnabled, state.morningSummaryEnabled);
    await prefs.setInt(_kMorningMinutes, state.morningSummaryMinutes);
    await prefs.setBool(_kWeeklyEnabled, state.weeklyReviewEnabled);
    await prefs.setInt(_kWeeklyMinutes, state.weeklyReviewMinutes);
  }
}

