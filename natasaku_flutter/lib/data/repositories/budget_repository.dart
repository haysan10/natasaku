import 'dart:math';
import '../datasources/local/local_storage.dart';
import '../models/budget_mode.dart';
import '../models/budget_period.dart';
import '../models/category_budget.dart';
import '../models/daily_closing.dart';
import '../models/daily_habit_log.dart';
import '../models/saving_goal.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction.dart';
import '../models/achievement_model.dart';
import '../models/fixed_expense_item.dart';
import '../models/usage_style.dart';
import '../models/user_settings.dart';
import '../models/debt_model.dart';
import '../models/in_app_notification.dart';
import 'package:flutter/material.dart';

import '../../core/services/habit_service.dart';
import '../../features/budgeting/budgeting_engine.dart';

class BudgetRepository {
  BudgetRepository(this._localStorage);

  final LocalStorage _localStorage;

  int _readMoney(Object? raw) => (raw as num?)?.round() ?? 0;

  Future<void> savePeriod(BudgetPeriod period) {
    return _localStorage.saveBudgetPeriod({
      'id': period.id,
      'startDate': period.startDate.toIso8601String(),
      'endDate': period.endDate.toIso8601String(),
      'flexibleFund': period.flexibleFund,
      'fixedExpenses': period.fixedExpenses,
      'monthlySavingAllocation': period.monthlySavingAllocation,
      'mode': period.mode.name,
    });
  }

  Future<BudgetPeriod?> loadPeriod() async {
    final payload = await _localStorage.getBudgetPeriod();
    if (payload == null) return null;

    final id = payload['id'] as String?;
    final startStr = payload['startDate'] as String?;
    final endStr = payload['endDate'] as String?;

    if (id == null || id.isEmpty || startStr == null || startStr.isEmpty || endStr == null || endStr.isEmpty) {
      return null;
    }

    try {
      return BudgetPeriod(
        id: id,
        startDate: DateTime.parse(startStr),
        endDate: DateTime.parse(endStr),
        flexibleFund: _readMoney(payload['flexibleFund']),
        fixedExpenses: _readMoney(payload['fixedExpenses']),
        monthlySavingAllocation: _readMoney(payload['monthlySavingAllocation']),
        mode: BudgetMode.values.firstWhere(
          (v) => v.name == payload['mode'],
          orElse: () => BudgetMode.normal,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<TransactionModel>> loadTransactions() async {
    final items = await _localStorage.getTransactions();
    final list = <TransactionModel>[];
    for (final item in items) {
      try {
        final id = item['id'] as String?;
        final dateStr = item['date'] as String?;
        if (id == null || dateStr == null) continue;
        list.add(TransactionModel.fromJson(item));
      } catch (_) {
        // Skip corrupt transaction item
      }
    }
    return list;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final all = await loadTransactions();
    all.add(transaction);
    await _localStorage.saveTransactions(
      all.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final all = await loadTransactions();
    final index = all.indexWhere((item) => item.id == transaction.id);
    if (index < 0) {
      all.add(transaction);
    } else {
      all[index] = transaction;
    }
    await _localStorage.saveTransactions(
      all.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final all = await loadTransactions();
    await _localStorage.saveTransactions(
      all.where((item) => item.id != id).map((t) => t.toJson()).toList(),
    );
  }

  Future<List<DailyClosing>> loadDailyClosings() async {
    final items = await _localStorage.getDailyClosings();
    return items
        .map(
          (item) => DailyClosing(
            date: DateTime.parse(item['date'] as String),
            finalExpense: _readMoney(item['finalExpense']),
            carryOver: _readMoney(item['carryOver']),
            note: item['note'] as String?,
          ),
        )
        .toList();
  }

  Future<void> addDailyClosing(DailyClosing closing) async {
    final all = await loadDailyClosings();
    final filtered =
        all.where((c) => !_isSameDay(c.date, closing.date)).toList();
    filtered.add(closing);

    await _localStorage.saveDailyClosings(
      filtered
          .map(
            (c) => {
              'date': c.date.toIso8601String(),
              'finalExpense': c.finalExpense,
              'carryOver': c.carryOver,
              'note': c.note,
            },
          )
          .toList(),
    );

    await saveHabitLog(
      HabitService.upsertLog(
        await loadHabitLogs(),
        closing.date,
        eveningCloseDone: true,
      ),
    );
  }

  Future<List<DailyHabitLog>> loadHabitLogs() async {
    final items = await _localStorage.getDailyHabitLogs();
    return items.map(DailyHabitLog.fromJson).toList();
  }

  Future<void> saveHabitLogs(List<DailyHabitLog> logs) async {
    await _localStorage.saveDailyHabitLogs(logs.map((l) => l.toJson()).toList());
  }

  Future<void> saveHabitLog(DailyHabitLog log) async {
    final merged = HabitService.mergeLog(await loadHabitLogs(), log);
    await saveHabitLogs(merged);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> saveUserSettings(UserSettings settings) {
    return _localStorage.saveUserSettings({
      'dailyReminderEnabled': settings.dailyReminderEnabled,
      'dailyReminderTime': settings.dailyReminderTime,
      'quickToolsNotificationEnabled': settings.quickToolsNotificationEnabled,
      'autoSavingEnabled': settings.autoSavingEnabled,
      'themeMode': settings.themeMode.name,
      'budgetMode': settings.budgetMode.name,
      'usageStyle': settings.usageStyle.name,
    });
  }

  Future<UserSettings> loadUserSettings() async {
    final payload = await _localStorage.getUserSettings();
    if (payload == null) return const UserSettings();

    return UserSettings(
      dailyReminderEnabled: payload['dailyReminderEnabled'] as bool? ?? false,
      dailyReminderTime: payload['dailyReminderTime'] as String? ?? '20:00',
      quickToolsNotificationEnabled:
          payload['quickToolsNotificationEnabled'] as bool? ?? true,
      autoSavingEnabled: payload['autoSavingEnabled'] as bool? ?? true,
      themeMode: ThemeMode.values.firstWhere(
        (v) => v.name == payload['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      budgetMode: BudgetMode.values.firstWhere(
        (v) => v.name == payload['budgetMode'],
        orElse: () => BudgetMode.normal,
      ),
      usageStyle: UsageStyle.values.firstWhere(
        (v) => v.name == payload['usageStyle'],
        orElse: () => UsageStyle.cepat,
      ),
    );
  }

  Future<int> loadSavingBalance() => _localStorage.getSavingBalance();

  Future<List<Map<String, dynamic>>> loadSavingAllocations() =>
      _localStorage.getSavingAllocations();

  Future<void> saveSavingGoal(SavingGoal goal) {
    return _localStorage.saveSavingGoal({
      'id': goal.id,
      'name': goal.name,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'targetDate': goal.targetDate?.toIso8601String(),
    });
  }

  Future<SavingGoal?> loadSavingGoal() async {
    try {
      final payload = await _localStorage.getSavingGoal();
      if (payload == null) return null;

      final id = payload['id'] as String?;
      final name = payload['name'] as String?;
      if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

      return SavingGoal(
        id: id,
        name: name,
        targetAmount: _readMoney(payload['targetAmount']),
        currentAmount: _readMoney(payload['currentAmount']),
        targetDate: payload['targetDate'] == null
            ? null
            : DateTime.tryParse(payload['targetDate'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSavingGoal() => _localStorage.clearSavingGoal();

  Future<void> addAutoSavingAllocation({
    required int amount,
    required DateTime date,
    String source = 'daily_closing',
  }) async {
    if (amount <= 0) return;

    final currentBalance = await loadSavingBalance();
    await _localStorage.saveSavingBalance(currentBalance + amount);

    final history = await loadSavingAllocations();
    history.add({
      'date': date.toIso8601String(),
      'amount': amount,
      'source': source,
    });
    await _localStorage.saveSavingAllocations(history);
  }

  Future<Map<String, String?>> exportRawData() =>
      _localStorage.exportManagedRaw();

  Future<void> importRawData(Map<String, dynamic> payload) =>
      _localStorage.importManagedRaw(payload);

  Future<void> markDashboardTutorialSeen() =>
      _localStorage.saveDashboardTutorialSeen(true);

  Future<bool> hasSeenDashboardTutorial() =>
      _localStorage.getDashboardTutorialSeen();

  Future<void> saveOnboardingComplete(bool value) =>
      _localStorage.saveOnboardingComplete(value);

  Future<bool> getOnboardingComplete() =>
      _localStorage.getOnboardingComplete();

  // ─── Category Budgets ────────────────────────────────────────────────────────

  Future<List<CategoryBudget>> loadCategoryBudgets() async {
    final items = await _localStorage.getCategoryBudgets();
    return items.map(CategoryBudget.fromMap).toList();
  }

  Future<void> saveCategoryBudgets(List<CategoryBudget> budgets) {
    return _localStorage.saveCategoryBudgets(
      budgets.map((b) => b.toMap()).toList(),
    );
  }

  Future<void> upsertCategoryBudget(CategoryBudget budget) async {
    final all = await loadCategoryBudgets();
    final idx = all.indexWhere((b) => b.id == budget.id);
    if (idx >= 0) {
      all[idx] = budget;
    } else {
      all.add(budget);
    }
    await saveCategoryBudgets(all);
  }

  Future<void> deleteCategoryBudget(String id) async {
    final all = await loadCategoryBudgets();
    await saveCategoryBudgets(all.where((b) => b.id != id).toList());
  }

  // ─── Multiple Saving Goals ───────────────────────────────────────────────────

  Future<List<SavingGoal>> loadSavingGoals() async {
    final items = await _localStorage.getSavingGoals();
    return items.map((m) => SavingGoal.fromJson(m)).toList();
  }

  Future<void> saveAllSavingGoals(List<SavingGoal> goals) {
    return _localStorage.saveSavingGoals(
      goals.map((g) => g.toJson()).toList(),
    );
  }

  Future<void> upsertSavingGoal(SavingGoal goal) async {
    final all = await loadSavingGoals();
    final idx = all.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) {
      all[idx] = goal;
    } else {
      all.add(goal);
    }
    await saveAllSavingGoals(all);
  }

  Future<void> deleteSavingGoalById(String id) async {
    final all = await loadSavingGoals();
    await saveAllSavingGoals(all.where((g) => g.id != id).toList());
  }

  // ─── Fixed Expense Items v2 ──────────────────────────────────────────────────

  Future<List<FixedExpenseItem>> loadFixedExpenseItems() async {
    final raw = await _localStorage.getFixedExpenseItems();
    if (raw.isEmpty) {
      // Legacy migration
      final period = await loadPeriod();
      if (period != null && period.fixedExpenses > 0) {
        final migratedItem = FixedExpenseItem(
          id: 'migrated_legacy',
          name: 'Tagihan Lainnya',
          amount: period.fixedExpenses,
          category: FixedExpenseCategory.lainnya,
          emoji: '📦',
          isActive: true,
        );
        final list = [migratedItem];
        await saveFixedExpenseItems(list);
        return list;
      }
      return <FixedExpenseItem>[];
    }
    return raw.map((json) => FixedExpenseItem.fromJson(json)).toList();
  }

  Future<void> saveFixedExpenseItems(List<FixedExpenseItem> items) async {
    await _localStorage.saveFixedExpenseItems(
      items.map((i) => i.toJson()).toList(),
    );
  }

  // ─── Recurring Transactions ─────────────────────────────────────────────────

  Future<List<RecurringTransaction>> loadRecurringTransactions() async {
    final items = await _localStorage.getRecurringTransactions();
    return items.map((m) => RecurringTransaction.fromJson(m)).toList();
  }

  Future<void> saveAllRecurringTransactions(List<RecurringTransaction> items) {
    return _localStorage.saveRecurringTransactions(
      items.map((r) => r.toJson()).toList(),
    );
  }

  Future<void> upsertRecurringTransaction(RecurringTransaction item) async {
    final all = await loadRecurringTransactions();
    final idx = all.indexWhere((r) => r.id == item.id);
    if (idx >= 0) {
      all[idx] = item;
    } else {
      all.add(item);
    }
    await saveAllRecurringTransactions(all);
  }

  Future<void> deleteRecurringTransaction(String id) async {
    final all = await loadRecurringTransactions();
    await saveAllRecurringTransactions(all.where((r) => r.id != id).toList());
  }

  // ─── Achievements ──────────────────────────────────────────────────────────

  Future<List<Achievement>> loadAchievements() async {
    final items = await _localStorage.getAchievements();
    return items.map((m) => Achievement.fromJson(m)).toList();
  }

  Future<void> saveAchievements(List<Achievement> achievements) {
    return _localStorage.saveAchievements(
      achievements.map((a) => a.toJson()).toList(),
    );
  }

  // ─── Quick Amount Presets ──────────────────────────────────────────────────

  Future<List<int>> loadQuickAmountPresets() async {
    final presets = await _localStorage.getQuickAmountPresets();
    if (presets.isEmpty) return [10000, 25000, 50000, 100000];
    return presets;
  }

  Future<void> saveQuickAmountPresets(List<int> presets) {
    return _localStorage.saveQuickAmountPresets(presets);
  }

  // ─── Daily Budget Adjustment ───────────────────────────────────────────────

  Future<void> saveDailyBudgetAdjustment(int value) =>
      _localStorage.saveDailyBudgetAdjustment(value);

  Future<int> getDailyBudgetAdjustment() =>
      _localStorage.getDailyBudgetAdjustment();

  Future<void> saveDailyBudgetAdjustmentDate(String? value) =>
      _localStorage.saveDailyBudgetAdjustmentDate(value);

  Future<String?> getDailyBudgetAdjustmentDate() =>
      _localStorage.getDailyBudgetAdjustmentDate();

  Future<void> resolveDailyBudgetAdjustment(
    DateTime today,
    BudgetPeriod period,
    List<TransactionModel> transactions,
  ) async {
    final adj = await getDailyBudgetAdjustment();
    if (adj == 0) return;
    final adjDateStr = await getDailyBudgetAdjustmentDate();
    if (adjDateStr == null) return;

    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    if (adjDateStr == todayStr) return; // Still active today

    final adjDate = DateTime.parse(adjDateStr);
    if (adj > 0) {
      // Positive carryover is single-day. Clear it once that day passes.
      await saveDailyBudgetAdjustment(0);
      await saveDailyBudgetAdjustmentDate(null);
    } else {
      // Deficit debt. Compute baseDaily of the adjDate.
      final remainingDaysOnAdjDate = max<int>(1, period.endDate.difference(adjDate).inDays + 1);
      
      // Load all transactions before the adjDate
      final txsBeforeAdjDate = transactions
          .where((t) => t.date.isBefore(DateTime(adjDate.year, adjDate.month, adjDate.day)))
          .toList();
      
      final totalIncomeBefore = txsBeforeAdjDate.where((t) => !t.isExpense).fold(0, (a, b) => a + b.amount);
      final totalExpenseBefore = txsBeforeAdjDate.where((t) => t.isExpense).fold(0, (a, b) => a + b.amount);

      final remainingFundBefore = BudgetingEngine.calculateRemainingFund(
        flexibleFund: period.flexibleFund,
        fixedExpenses: period.fixedExpenses,
        monthlySavingAllocation: period.monthlySavingAllocation,
        totalIncome: totalIncomeBefore,
        totalExpense: totalExpenseBefore,
        incomeAmounts: txsBeforeAdjDate.where((t) => !t.isExpense).map((t) => t.amount),
      );

      final baseDaily = BudgetingEngine.calculateDailySafeBudget(
        remainingFund: remainingFundBefore,
        remainingDays: remainingDaysOnAdjDate,
      );

      final debtPaid = baseDaily;
      final remainingDebt = (adj.abs() - debtPaid).toInt();

      if (remainingDebt <= 0) {
        await saveDailyBudgetAdjustment(0);
        await saveDailyBudgetAdjustmentDate(null);
      } else {
        await saveDailyBudgetAdjustment(-remainingDebt);
        await saveDailyBudgetAdjustmentDate(todayStr);
      }
    }
  }

  // ─── Debts ─────────────────────────────────────────────────────────────────
  Future<List<DebtModel>> loadDebts() async {
    final items = await _localStorage.getDebts();
    return items.map((m) => DebtModel.fromJson(m)).toList();
  }

  Future<void> saveAllDebts(List<DebtModel> debts) async {
    await _localStorage.saveDebts(debts.map((d) => d.toJson()).toList());
  }

  Future<void> upsertDebt(DebtModel debt) async {
    final all = await loadDebts();
    final idx = all.indexWhere((d) => d.id == debt.id);
    if (idx >= 0) {
      all[idx] = debt;
    } else {
      all.add(debt);
    }
    await saveAllDebts(all);
  }

  Future<void> deleteDebt(String id) async {
    final all = await loadDebts();
    await saveAllDebts(all.where((d) => d.id != id).toList());
  }

  // ─── In-App Notifications ──────────────────────────────────────────────────
  Future<List<InAppNotification>> loadInAppNotifications() async {
    final items = await _localStorage.getInAppNotifications();
    return items.map((m) => InAppNotification.fromJson(m)).toList();
  }

  Future<void> saveInAppNotifications(List<InAppNotification> notifications) async {
    await _localStorage.saveInAppNotifications(notifications.map((n) => n.toJson()).toList());
  }

  Future<void> addInAppNotification(InAppNotification notification) async {
    final all = await loadInAppNotifications();
    all.add(notification);
    await saveInAppNotifications(all);
  }

  Future<void> markNotificationsAsRead() async {
    final all = await loadInAppNotifications();
    final updated = all.map((n) => n.copyWith(isRead: true)).toList();
    await saveInAppNotifications(updated);
  }

  // ─── XP & Gamification ────────────────────────────────────────────────────
  Future<int> getXp() => _localStorage.getUserXp();
  Future<void> saveXp(int value) => _localStorage.saveUserXp(value);
}
