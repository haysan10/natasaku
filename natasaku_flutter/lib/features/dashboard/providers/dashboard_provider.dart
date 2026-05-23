import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../data/models/budget_period.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/budget_status.dart';
import '../../../data/models/saving_goal.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/models/bill_model.dart';
import '../../budgeting/budgeting_engine.dart';
import '../../../core/services/android_widget_service.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/sound/nata_sound_player.dart';

class DashboardState {
  final BudgetPeriod? period;
  final List<TransactionModel> transactions;
  final SavingGoal? savingGoal;
  final List<SavingGoal> savingGoals;
  final UserSettings? userSettings;
  final bool isLoading;

  const DashboardState({
    this.period,
    this.transactions = const [],
    this.savingGoal,
    this.savingGoals = const [],
    this.userSettings,
    this.isLoading = true,
  });

  DashboardState copyWith({
    BudgetPeriod? period,
    List<TransactionModel>? transactions,
    SavingGoal? savingGoal,
    List<SavingGoal>? savingGoals,
    UserSettings? userSettings,
    bool? isLoading,
  }) {
    return DashboardState(
      period: period ?? this.period,
      transactions: transactions ?? this.transactions,
      savingGoal: savingGoal ?? this.savingGoal,
      savingGoals: savingGoals ?? this.savingGoals,
      userSettings: userSettings ?? this.userSettings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Helper getters for UI
  int get totalIncome => transactions.where((t) => !t.isExpense).fold(0, (a, b) => a + b.amount);
  int get totalExpense => transactions.where((t) => t.isExpense).fold(0, (a, b) => a + b.amount);
  
  int get remainingFund {
    if (period == null) return 0;
    return period!.flexibleFund
        - period!.fixedExpenses
        - period!.monthlySavingAllocation
        + totalIncome
        - totalExpense;
  }

  int get todayExpense {
    final today = DateTime.now();
    return transactions
        .where((t) => t.isExpense)
        .where((t) => t.date.year == today.year && t.date.month == today.month && t.date.day == today.day)
        .fold(0, (a, b) => a + b.amount);
  }

  int get remainingDays {
    if (period == null) return 0;
    return max(
      0,
      BudgetingEngine.calculateRemainingDays(
        today: DateTime.now(),
        periodEnd: period!.endDate,
      ),
    );
  }

  int get dailySafeBudget {
    if (period == null) return 0;
    final baseDaily = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max(remainingFund, 0),
      remainingDays: remainingDays,
    );
    return BudgetingEngine.applyBudgetMode(baseDailyBudget: baseDaily, mode: period!.mode);
  }

  DailyBudgetStatus get dailyStatus {
    return BudgetingEngine.getDailyBudgetStatus(todayExpense: todayExpense, dailySafeBudget: dailySafeBudget);
  }

  int get healthScore {
    var score = 78;
    final netBalance = remainingFund;
    final periodUsage = period == null || period!.flexibleFund <= 0 
        ? 0.0 : (totalExpense / period!.flexibleFund);
    
    final periodStatus = period == null ? null : BudgetingEngine.getPeriodFundStatus(
      remainingFund: netBalance,
      remainingDays: remainingDays,
    );

    if (netBalance < 0) score -= 28;
    if (periodUsage > 0.85) score -= 16;
    if (periodUsage < 0.55) score += 8;
    if (periodStatus == PeriodFundStatus.aman) score += 8;
    if (periodStatus == PeriodFundStatus.kritis || periodStatus == PeriodFundStatus.danaHabis) score -= 18;
    return score.clamp(0, 100);
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;
  bool _hasPlayedWarningThisSession = false;

  DashboardNotifier(this._ref) : super(const DashboardState()) {
    loadData();
  }

  void _playSound(Future<void> Function() sound) {
    unawaited(sound());
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(budgetRepositoryProvider);
    final localStorage = _ref.read(localStorageProvider);
    
    var period = await repo.loadPeriod();
    var transactions = await repo.loadTransactions();
    var savingGoal = await repo.loadSavingGoal();
    var savingGoals = await repo.loadSavingGoals();
    final userSettings = await repo.loadUserSettings();

    // Automated Scheduler Check
    if (period != null) {
      final today = DateTime.now();
      bool dataChanged = false;

      // 1. Process Automated Bill Payments
      final rawBills = await localStorage.getBills();
      var bills = rawBills.map((e) => BillModel.fromJson(e)).toList();
      bool billsChanged = false;

      for (int i = 0; i < bills.length; i++) {
        var bill = bills[i];
        final currentMonthStart = DateTime(today.year, today.month, 1);
        final lastPayDate = bill.lastPaymentDate != null 
            ? DateTime.tryParse(bill.lastPaymentDate!) 
            : (bill.lastAutoPayDate != null ? DateTime.tryParse(bill.lastAutoPayDate!) : null);

        // Perform Month-Rollover check
        if (bill.isPaid && lastPayDate != null && lastPayDate.isBefore(currentMonthStart)) {
          bill = bill.copyWith(isPaid: false);
          bills[i] = bill;
          billsChanged = true;
        }

        if (bill.isAutoPay && !bill.isPaid && bill.dueDate != null) {
          if (today.day >= bill.dueDate! && (lastPayDate == null || lastPayDate.isBefore(currentMonthStart))) {
            bills[i] = bill.copyWith(
              isPaid: true,
              lastPaymentDate: today.toIso8601String(),
              lastAutoPayDate: today.toIso8601String(),
            );
            billsChanged = true;
            dataChanged = true;

            final tx = TransactionModel(
              id: 'autobill_${bill.id}_${today.year}_${today.month}',
              date: today,
              amount: bill.amount,
              isExpense: true,
              category: 'Tagihan',
              note: 'Pembayaran otomatis: ${bill.name}',
            );
            await repo.addTransaction(tx);
          }
        }
      }
      if (billsChanged) {
        await localStorage.saveBills(bills.map((e) => e.toJson()).toList());
      }

      // 2. Process Automated Savings Allocations
      bool goalsChanged = false;
      for (int i = 0; i < savingGoals.length; i++) {
        final goal = savingGoals[i];
        if (goal.autoSaveAmount != null && goal.autoSaveAmount! > 0 && goal.autoSaveFrequency != null) {
          final lastSave = goal.lastAutoSaveDate;
          bool isDue = false;
          if (lastSave == null) {
            isDue = true;
          } else {
            final todayZero = DateTime(today.year, today.month, today.day);
            final lastSaveZero = DateTime(lastSave.year, lastSave.month, lastSave.day);
            final diff = todayZero.difference(lastSaveZero).inDays;
            
            if (goal.autoSaveFrequency == 'daily' && diff >= 1) {
              isDue = true;
            } else if (goal.autoSaveFrequency == 'weekly' && diff >= 7) {
              isDue = true;
            } else if (goal.autoSaveFrequency == 'monthly' && diff >= 30) {
              isDue = true;
            }
          }

          if (isDue) {
            savingGoals[i] = goal.copyWith(
              currentAmount: goal.currentAmount + goal.autoSaveAmount!,
              lastAutoSaveDate: today,
            );
            goalsChanged = true;
            dataChanged = true;

            final tx = TransactionModel(
              id: 'autosave_${goal.id}_${today.millisecondsSinceEpoch}',
              date: today,
              amount: goal.autoSaveAmount!,
              isExpense: true,
              category: 'Menabung',
              note: 'Tabungan otomatis: ${goal.name}',
            );
            await repo.addTransaction(tx);
          }
        }
      }
      if (goalsChanged) {
        await repo.saveAllSavingGoals(savingGoals);
      }

      // If transactions or saving goals were updated, reload them!
      if (dataChanged) {
        transactions = await repo.loadTransactions();
        savingGoals = await repo.loadSavingGoals();
        savingGoal = await repo.loadSavingGoal();
      }
    }
    
    state = state.copyWith(
      period: period,
      transactions: transactions,
      savingGoal: savingGoal,
      savingGoals: savingGoals,
      userSettings: userSettings,
      isLoading: false,
    );
    
    _syncHomeWidget();
  }

  Future<void> transferToSavings(int amount) async {
    final period = state.period;
    final goal = state.savingGoal;
    if (period == null || goal == null) return;

    final repo = _ref.read(budgetRepositoryProvider);

    // Create an expense transaction for the savings sweep
    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      isExpense: true,
      category: 'Menabung',
      note: 'Sisa Jatah Harian 🚀',
    );
    await repo.addTransaction(transaction);

    // Update saving goal
    final updatedGoal = SavingGoal(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount + amount,
      targetDate: goal.targetDate,
    );
    await repo.saveSavingGoal(updatedGoal);

    final wasReached = goal.currentAmount >= goal.targetAmount;
    final isReached = updatedGoal.currentAmount >= goal.targetAmount;

    await loadData();

    if (isReached && !wasReached && goal.targetAmount > 0) {
      _playSound(NataSoundPlayer.playAchievement);
    } else {
      _playSound(NataSoundPlayer.playSuccess);
    }
  }

  Future<void> transferToGoal(int amount, SavingGoal goal) async {
    final period = state.period;
    if (period == null) return;

    final repo = _ref.read(budgetRepositoryProvider);

    // Create an expense transaction for the savings sweep
    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      amount: amount,
      isExpense: true,
      category: 'Menabung',
      note: 'Transfer ke "${goal.name}" 🚀',
    );
    await repo.addTransaction(transaction);

    // Update saving goal
    final updatedGoal = SavingGoal(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount + amount,
      targetDate: goal.targetDate,
    );
    await repo.upsertSavingGoal(updatedGoal);

    final wasReached = goal.currentAmount >= goal.targetAmount;
    final isReached = updatedGoal.currentAmount >= goal.targetAmount;

    await loadData();

    if (isReached && !wasReached && goal.targetAmount > 0) {
      _playSound(NataSoundPlayer.playAchievement);
    } else {
      _playSound(NataSoundPlayer.playSuccess);
    }
  }

  Future<void> updateAutoSaving(bool enabled) async {
    final repo = _ref.read(budgetRepositoryProvider);
    final currentSettings = state.userSettings ?? const UserSettings();
    final updated = currentSettings.copyWith(autoSavingEnabled: enabled);
    await repo.saveUserSettings(updated);
    await loadData();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final wasOver = state.todayExpense > state.dailySafeBudget;
    
    final repo = _ref.read(budgetRepositoryProvider);
    await repo.addTransaction(transaction);
    await loadData();

    final isOver = state.todayExpense > state.dailySafeBudget;
    if (isOver && !wasOver && transaction.isExpense) {
      if (!_hasPlayedWarningThisSession) {
        _hasPlayedWarningThisSession = true;
        _playSound(NataSoundPlayer.playWarning);
      }
    } else {
      _playSound(NataSoundPlayer.playSuccess);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final repo = _ref.read(budgetRepositoryProvider);
    final all = await repo.loadTransactions();
    final filtered = all.where((item) => item.id != id).toList();
    
    // Save back
    final storage = _ref.read(localStorageProvider);
    await storage.saveTransactions(
      filtered.map((t) => {
        'id': t.id,
        'date': t.date.toIso8601String(),
        'amount': t.amount,
        'isExpense': t.isExpense,
        'note': t.note,
        'category': t.category,
      }).toList(),
    );
    
    await loadData();
    _playSound(NataSoundPlayer.playDelete);
  }

  Future<void> _syncHomeWidget() async {
    try {
      final period = state.period;
      final repo = _ref.read(budgetRepositoryProvider);
      
      final userSettings = await repo.loadUserSettings();
      try {
        await AndroidWidgetService.setQuickToolsNotificationEnabled(userSettings.quickToolsNotificationEnabled);
      } catch (_) {
        // Safe to ignore on iOS or non-supported platforms
      }

      if (period == null) {
        try {
          await AndroidWidgetService.updateHomeWidget(
            dailySafeBudget: 'Rp0',
            dailyStatus: 'Atur dulu',
            periodStatus: 'Belum aktif',
            remainingFund: 'Rp0',
            todayExpense: 'Rp0',
            tomorrowBudget: 'Rp0',
            advice: 'Buka NataSaku lalu atur periode agar hitungan aktif.',
            dailySafeBudgetAmount: 0,
            remainingFundAmount: 0,
            todayExpenseAmount: 0,
          );
        } catch (_) {}
        return;
      }

      final safeDaily = state.dailySafeBudget;
      final remainingFund = state.remainingFund;
      final todayExpense = state.todayExpense;
      final remainingDays = state.remainingDays;
      
      final tomorrowBudget = BudgetingEngine.calculateTomorrowSafeBudget(
        remainingFundAfterToday: remainingFund - todayExpense,
        remainingDaysAfterToday: max(remainingDays - 1, 0),
      );
      
      final dailyStatus = state.dailyStatus;
      final periodStatus = BudgetingEngine.getPeriodFundStatus(
        remainingFund: remainingFund,
        remainingDays: remainingDays,
      );
      
      final adviceText = BudgetingEngine.generateDynamicRecommendation(
        dailyStatus: dailyStatus,
        periodStatus: periodStatus,
      );
      
      final usage = BudgetingEngine.calculateTodayBudgetUsage(
        todayExpense: todayExpense,
        dailySafeBudget: safeDaily,
      );
      
      try {
        await AndroidWidgetService.updateHomeWidget(
          dailySafeBudget: CurrencyService.formatRupiah(safeDaily),
          dailyStatus: _dailyStatusLabel(dailyStatus),
          periodStatus: _periodStatusLabel(periodStatus),
          remainingFund: CurrencyService.formatRupiah(remainingFund),
          todayExpense: CurrencyService.formatRupiah(todayExpense),
          tomorrowBudget: CurrencyService.formatRupiah(tomorrowBudget),
          advice: adviceText,
          remainingDays: 'Sisa ${max(remainingDays, 0)} hari',
          usagePercent: (usage * 100).isFinite ? (usage * 100).round().clamp(0, 100) : 0,
          dailySafeBudgetAmount: safeDaily,
          remainingFundAmount: remainingFund,
          todayExpenseAmount: todayExpense,
        );
      } catch (_) {}
    } catch (_) {
      // Catch-all to make sure dashboard provider never crashes due to home widget updates
    }
  }

  String _dailyStatusLabel(DailyBudgetStatus status) {
    switch (status) {
      case DailyBudgetStatus.belumAdaPengeluaran: return 'Aman';
      case DailyBudgetStatus.aman: return 'Aman';
      case DailyBudgetStatus.mendekatiBatas: return 'Hati-hati';
      case DailyBudgetStatus.melebihiSedikit: return 'Hati-hati';
      case DailyBudgetStatus.boros: return 'Boros';
    }
  }

  String _periodStatusLabel(PeriodFundStatus status) {
    switch (status) {
      case PeriodFundStatus.aman: return 'Sehat';
      case PeriodFundStatus.waspada: return 'Waspada';
      case PeriodFundStatus.kritis: return 'Kritis';
      case PeriodFundStatus.danaHabis: return 'Dana Habis';
      case PeriodFundStatus.periodeSelesai: return 'Selesai';
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
