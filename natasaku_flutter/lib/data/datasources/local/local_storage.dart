import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _budgetPeriodKey = 'budget_period';
  static const _transactionsKey = 'transactions';
  static const _dailyClosingsKey = 'daily_closings';
  static const _userSettingsKey = 'user_settings';
  static const _savingBalanceKey = 'saving_balance';
  static const _savingAllocationsKey = 'saving_allocations';
  static const _dashboardTutorialSeenKey = 'dashboard_tutorial_seen';

  Future<void> saveBudgetPeriod(Map<String, dynamic> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_budgetPeriodKey, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getBudgetPeriod() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_budgetPeriodKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveTransactions(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_transactionsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_transactionsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<void> saveDailyClosings(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_dailyClosingsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getDailyClosings() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_dailyClosingsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<void> saveUserSettings(Map<String, dynamic> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_userSettingsKey, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getUserSettings() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_userSettingsKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSavingBalance(double value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble(_savingBalanceKey, value);
  }

  Future<double> getSavingBalance() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(_savingBalanceKey) ?? 0;
  }

  Future<void> saveSavingAllocations(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_savingAllocationsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getSavingAllocations() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_savingAllocationsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<Map<String, String?>> exportManagedRaw() async {
    final pref = await SharedPreferences.getInstance();
    const keys = <String>[
      _budgetPeriodKey,
      _transactionsKey,
      _dailyClosingsKey,
      _userSettingsKey,
      _savingAllocationsKey,
    ];

    final mapped = <String, String?>{};
    for (final key in keys) {
      mapped[key] = pref.getString(key);
    }
    mapped[_savingBalanceKey] = pref.getDouble(_savingBalanceKey)?.toString();
    return mapped;
  }

  Future<void> importManagedRaw(Map<String, dynamic> raw) async {
    final pref = await SharedPreferences.getInstance();
    final entries = raw.cast<String, dynamic>();

    for (final entry in entries.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key == _savingBalanceKey) {
        final parsed = double.tryParse(value?.toString() ?? '');
        if (parsed == null) {
          await pref.remove(_savingBalanceKey);
        } else {
          await pref.setDouble(_savingBalanceKey, parsed);
        }
        continue;
      }

      if (value == null) {
        await pref.remove(key);
      } else {
        await pref.setString(key, value.toString());
      }
    }
  }

  Future<void> saveDashboardTutorialSeen(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(_dashboardTutorialSeenKey, value);
  }

  Future<bool> getDashboardTutorialSeen() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_dashboardTutorialSeenKey) ?? false;
  }
}
