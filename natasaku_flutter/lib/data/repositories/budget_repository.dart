import '../datasources/local/local_storage.dart';
import '../models/budget_mode.dart';
import '../models/budget_period.dart';
import '../models/category_budget.dart';
import '../models/daily_closing.dart';
import '../models/saving_goal.dart';
import '../models/transaction_model.dart';
import '../models/usage_style.dart';
import '../models/user_settings.dart';

class BudgetRepository {
  BudgetRepository(this._localStorage);

  final LocalStorage _localStorage;

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
        flexibleFund: (payload['flexibleFund'] as num?)?.toDouble() ?? 0.0,
        fixedExpenses: (payload['fixedExpenses'] as num?)?.toDouble() ?? 0.0,
        monthlySavingAllocation: (payload['monthlySavingAllocation'] as num?)?.toDouble() ?? 0.0,
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

        list.add(
          TransactionModel(
            id: id,
            date: DateTime.parse(dateStr),
            amount: (item['amount'] as num?)?.toDouble() ?? 0.0,
            isExpense: item['isExpense'] as bool? ?? true,
            note: item['note'] as String?,
            category: item['category'] as String?,
          ),
        );
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
      all
          .map(
            (t) => {
              'id': t.id,
              'date': t.date.toIso8601String(),
              'amount': t.amount,
              'isExpense': t.isExpense,
              'note': t.note,
              'category': t.category,
            },
          )
          .toList(),
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
      all
          .map(
            (t) => {
              'id': t.id,
              'date': t.date.toIso8601String(),
              'amount': t.amount,
              'isExpense': t.isExpense,
              'note': t.note,
              'category': t.category,
            },
          )
          .toList(),
    );
  }

  Future<void> deleteTransaction(String id) async {
    final all = await loadTransactions();
    await _localStorage.saveTransactions(
      all
          .where((item) => item.id != id)
          .map(
            (t) => {
              'id': t.id,
              'date': t.date.toIso8601String(),
              'amount': t.amount,
              'isExpense': t.isExpense,
              'note': t.note,
              'category': t.category,
            },
          )
          .toList(),
    );
  }

  Future<List<DailyClosing>> loadDailyClosings() async {
    final items = await _localStorage.getDailyClosings();
    return items
        .map(
          (item) => DailyClosing(
            date: DateTime.parse(item['date'] as String),
            finalExpense: (item['finalExpense'] as num).toDouble(),
            carryOver: (item['carryOver'] as num).toDouble(),
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

  Future<double> loadSavingBalance() => _localStorage.getSavingBalance();

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
        targetAmount: (payload['targetAmount'] as num?)?.toDouble() ?? 0.0,
        currentAmount: (payload['currentAmount'] as num?)?.toDouble() ?? 0.0,
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
    required double amount,
    required DateTime date,
    String source = 'daily_closing',
  }) async {
    if (!amount.isFinite || amount <= 0) return;

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
}
