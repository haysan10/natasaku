import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _budgetPeriodKey = 'budget_period';
  static const _transactionsKey = 'transactions';
  static const _dailyClosingsKey = 'daily_closings';
  static const _userSettingsKey = 'user_settings';
  static const _savingBalanceKey = 'saving_balance';
  static const _savingAllocationsKey = 'saving_allocations';
  static const _savingGoalKey = 'saving_goal';
  static const _dashboardTutorialSeenKey = 'dashboard_tutorial_seen';
  static const _featureTourCompletedKey = 'feature_tour_completed';
  static const _categoryBudgetsKey = 'category_budgets';
  static const _savingGoalsKey = 'saving_goals';

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

  Future<void> saveSavingGoal(Map<String, dynamic> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_savingGoalKey, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getSavingGoal() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_savingGoalKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearSavingGoal() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_savingGoalKey);
  }

  Future<Map<String, String?>> exportManagedRaw() async {
    final pref = await SharedPreferences.getInstance();
    const keys = <String>[
      _budgetPeriodKey,
      _transactionsKey,
      _dailyClosingsKey,
      _userSettingsKey,
      _savingAllocationsKey,
      _savingGoalKey,
      _billsKey,
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

  /// Feature tour (post-setup spotlight tour) — berbeda dari onboarding tour
  Future<void> saveFeatureTourCompleted(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(_featureTourCompletedKey, value);
  }

  Future<bool> getFeatureTourCompleted() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(_featureTourCompletedKey) ?? false;
  }

  // Security / App Lock
  static const _appPinKey = 'app_pin_code';

  Future<void> saveAppPin(String? pin) async {
    final pref = await SharedPreferences.getInstance();
    if (pin == null || pin.isEmpty) {
      await pref.remove(_appPinKey);
    } else {
      await pref.setString(_appPinKey, pin);
    }
  }

  Future<String?> getAppPin() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_appPinKey);
  }

  // Bills
  static const _billsKey = 'bills_list';

  Future<void> saveBills(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_billsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_billsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // Category Budgets
  Future<void> saveCategoryBudgets(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_categoryBudgetsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getCategoryBudgets() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_categoryBudgetsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // Multiple Saving Goals
  Future<void> saveSavingGoals(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_savingGoalsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getSavingGoals() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_savingGoalsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }
}
