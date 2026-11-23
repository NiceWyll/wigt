import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._service) : super(const SettingsState()) {
    _load();
  }

  final SettingsService _service;

  Future<void> _load() async {
    final loaded = await _service.loadSettings();
    state = loaded;
  }

  Future<void> setMorningSummaryEnabled(bool enabled) async {
    state = state.copyWith(morningSummaryEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> setMorningSummaryMinutes(int minutes) async {
    state = state.copyWith(morningSummaryMinutes: minutes);
    await _service.saveSettings(state);
  }

  Future<void> setWeeklyReviewEnabled(bool enabled) async {
    state = state.copyWith(weeklyReviewEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> setWeeklyReviewMinutes(int minutes) async {
    state = state.copyWith(weeklyReviewMinutes: minutes);
    await _service.saveSettings(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});

