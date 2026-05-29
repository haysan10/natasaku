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
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _dashboardTutorialSeenKey = 'dashboard_tutorial_seen';
  static const _featureTourCompletedKey = 'feature_tour_completed';
  static const _categoryBudgetsKey = 'category_budgets';
  static const _savingGoalsKey = 'saving_goals';
  static const _dailyHabitLogsKey = 'daily_habit_logs';
  static const _recurringTransactionsKey = 'recurring_transactions';
  static const _achievementsKey = 'achievements';
  static const _quickAmountPresetsKey = 'quick_amount_presets';

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

  Future<void> saveSavingBalance(int value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_savingBalanceKey, value);
  }

  Future<int> getSavingBalance() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.get(_savingBalanceKey);
    if (raw is int) return raw;
    if (raw is double) {
      final migrated = raw.round();
      await pref.setInt(_savingBalanceKey, migrated);
      return migrated;
    }
    return 0;
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
    mapped[_onboardingCompleteKey] =
        pref.getBool(_onboardingCompleteKey)?.toString();
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
          await pref.setInt(_savingBalanceKey, parsed.round());
        }
        continue;
      }

      if (key == _onboardingCompleteKey) {
        final parsed = value is bool
            ? value
            : (value?.toString().toLowerCase() == 'true');
        await pref.setBool(_onboardingCompleteKey, parsed);
        continue;
      }

      if (value == null) {
        await pref.remove(key);
      } else {
        await pref.setString(key, value.toString());
      }
    }
  }

  Future<void> saveOnboardingComplete(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(_onboardingCompleteKey, value);
  }

  Future<bool> getOnboardingComplete() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(_onboardingCompleteKey)) {
      return pref.getBool(_onboardingCompleteKey) ?? false;
    }

    final rawPeriod = pref.getString(_budgetPeriodKey);
    final hasLegacyPeriod = rawPeriod != null && rawPeriod.isNotEmpty;
    if (hasLegacyPeriod) {
      await pref.setBool(_onboardingCompleteKey, true);
      return true;
    }
    return false;
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

  // Fixed Expense Items v2
  static const _fixedExpenseItemsKey = 'fixed_expense_items_v2';

  Future<void> saveFixedExpenseItems(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_fixedExpenseItemsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getFixedExpenseItems() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_fixedExpenseItemsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<void> saveDailyHabitLogs(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_dailyHabitLogsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getDailyHabitLogs() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_dailyHabitLogsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // ─── Recurring Transactions ─────────────────────────────────────────────────

  Future<void> saveRecurringTransactions(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_recurringTransactionsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getRecurringTransactions() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_recurringTransactionsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // ─── Achievements ──────────────────────────────────────────────────────────

  Future<void> saveAchievements(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_achievementsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_achievementsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // ─── Quick Amount Presets ──────────────────────────────────────────────────

  Future<void> saveQuickAmountPresets(List<int> presets) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_quickAmountPresetsKey, jsonEncode(presets));
  }

  Future<List<int>> getQuickAmountPresets() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_quickAmountPresetsKey);
    if (raw == null || raw.isEmpty) return <int>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => (item as num).round()).toList();
  }

  // ─── Daily Budget Adjustment ───────────────────────────────────────────────
  static const _dailyBudgetAdjustmentKey = 'daily_budget_adjustment';
  static const _dailyBudgetAdjustmentDateKey = 'daily_budget_adjustment_date';

  Future<void> saveDailyBudgetAdjustment(int value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_dailyBudgetAdjustmentKey, value);
  }

  Future<int> getDailyBudgetAdjustment() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(_dailyBudgetAdjustmentKey) ?? 0;
  }

  Future<void> saveDailyBudgetAdjustmentDate(String? value) async {
    final pref = await SharedPreferences.getInstance();
    if (value == null) {
      await pref.remove(_dailyBudgetAdjustmentDateKey);
    } else {
      await pref.setString(_dailyBudgetAdjustmentDateKey, value);
    }
  }

  Future<String?> getDailyBudgetAdjustmentDate() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_dailyBudgetAdjustmentDateKey);
  }

  // ─── Gamification & XP ─────────────────────────────────────────────────────
  static const _userXpKey = 'user_xp';

  Future<void> saveUserXp(int value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt(_userXpKey, value);
  }

  Future<int> getUserXp() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(_userXpKey) ?? 0;
  }

  // ─── Debts & receivables ──────────────────────────────────────────────────
  static const _debtsKey = 'debts_list';

  Future<void> saveDebts(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_debtsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getDebts() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_debtsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // ─── In-App Notifications ──────────────────────────────────────────────────
  static const _inAppNotificationsKey = 'in_app_notifications';

  Future<void> saveInAppNotifications(List<Map<String, dynamic>> payload) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_inAppNotificationsKey, jsonEncode(payload));
  }

  Future<List<Map<String, dynamic>>> getInAppNotifications() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_inAppNotificationsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }
}

