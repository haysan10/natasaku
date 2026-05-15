import '../datasources/local/local_storage.dart';
import '../models/budget_mode.dart';
import '../models/budget_period.dart';
import '../models/daily_closing.dart';
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
      'mode': period.mode.name,
    });
  }

  Future<BudgetPeriod?> loadPeriod() async {
    final payload = await _localStorage.getBudgetPeriod();
    if (payload == null) return null;

    return BudgetPeriod(
      id: payload['id'] as String,
      startDate: DateTime.parse(payload['startDate'] as String),
      endDate: DateTime.parse(payload['endDate'] as String),
      flexibleFund: (payload['flexibleFund'] as num).toDouble(),
      mode: BudgetMode.values.firstWhere(
        (v) => v.name == payload['mode'],
        orElse: () => BudgetMode.normal,
      ),
    );
  }

  Future<List<TransactionModel>> loadTransactions() async {
    final items = await _localStorage.getTransactions();
    return items
        .map(
          (item) => TransactionModel(
            id: item['id'] as String,
            date: DateTime.parse(item['date'] as String),
            amount: (item['amount'] as num).toDouble(),
            isExpense: item['isExpense'] as bool,
            note: item['note'] as String?,
            category: item['category'] as String?,
          ),
        )
        .toList();
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
}
