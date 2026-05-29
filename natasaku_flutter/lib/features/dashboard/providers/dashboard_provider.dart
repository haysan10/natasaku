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
import '../../../data/models/achievement_model.dart';
import '../../../data/models/recurring_transaction.dart';
import '../../budgeting/budgeting_engine.dart';
import '../../../core/services/android_widget_service.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/services/habit_service.dart';
import '../../../core/services/achievement_service.dart';
import '../../../core/sound/nata_sound_player.dart';
import '../../../data/models/daily_closing.dart';
import '../../../data/models/daily_habit_log.dart';
import '../../../data/models/in_app_notification.dart';

class DashboardState {
  final BudgetPeriod? period;
  final List<TransactionModel> transactions;
  final SavingGoal? savingGoal;
  final List<SavingGoal> savingGoals;
  final UserSettings? userSettings;
  final bool isLoading;
  final int loggingStreak;
  final int savingStreak;
  final bool eveningClosedToday;
  final String? yesterdayInsight;
  final List<String> weeklyInsightLines;
  final List<Achievement> achievements;
  final List<Achievement> newlyEarnedAchievements;
  final int dailyAdjustment;
  final String? dailyAdjustmentDate;

  final int userXp;
  final int userLevel;
  final List<InAppNotification> inAppNotifications;

  const DashboardState({
    this.period,
    this.transactions = const [],
    this.savingGoal,
    this.savingGoals = const [],
    this.userSettings,
    this.isLoading = true,
    this.loggingStreak = 0,
    this.savingStreak = 0,
    this.eveningClosedToday = false,
    this.yesterdayInsight,
    this.weeklyInsightLines = const [],
    this.achievements = const [],
    this.newlyEarnedAchievements = const [],
    this.dailyAdjustment = 0,
    this.dailyAdjustmentDate,
    this.userXp = 0,
    this.userLevel = 1,
    this.inAppNotifications = const [],
  });

  DashboardState copyWith({
    BudgetPeriod? period,
    List<TransactionModel>? transactions,
    SavingGoal? savingGoal,
    List<SavingGoal>? savingGoals,
    UserSettings? userSettings,
    bool? isLoading,
    int? loggingStreak,
    int? savingStreak,
    bool? eveningClosedToday,
    String? yesterdayInsight,
    List<String>? weeklyInsightLines,
    List<Achievement>? achievements,
    List<Achievement>? newlyEarnedAchievements,
    int? dailyAdjustment,
    String? dailyAdjustmentDate,
    int? userXp,
    int? userLevel,
    List<InAppNotification>? inAppNotifications,
  }) {
    return DashboardState(
      period: period ?? this.period,
      transactions: transactions ?? this.transactions,
      savingGoal: savingGoal ?? this.savingGoal,
      savingGoals: savingGoals ?? this.savingGoals,
      userSettings: userSettings ?? this.userSettings,
      isLoading: isLoading ?? this.isLoading,
      loggingStreak: loggingStreak ?? this.loggingStreak,
      savingStreak: savingStreak ?? this.savingStreak,
      eveningClosedToday: eveningClosedToday ?? this.eveningClosedToday,
      yesterdayInsight: yesterdayInsight ?? this.yesterdayInsight,
      weeklyInsightLines: weeklyInsightLines ?? this.weeklyInsightLines,
      achievements: achievements ?? this.achievements,
      newlyEarnedAchievements: newlyEarnedAchievements ?? this.newlyEarnedAchievements,
      dailyAdjustment: dailyAdjustment ?? this.dailyAdjustment,
      dailyAdjustmentDate: dailyAdjustmentDate ?? this.dailyAdjustmentDate,
      userXp: userXp ?? this.userXp,
      userLevel: userLevel ?? this.userLevel,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
    );
  }

  // Helper getters for UI
  int get totalIncome => transactions.where((t) => !t.isExpense).fold(0, (a, b) => a + b.amount);
  int get totalExpense => transactions.where((t) => t.isExpense).fold(0, (a, b) => a + b.amount);
  
  int get remainingFund {
    if (period == null) return 0;
    return BudgetingEngine.calculateRemainingFund(
      flexibleFund: period!.flexibleFund,
      fixedExpenses: period!.fixedExpenses,
      monthlySavingAllocation: period!.monthlySavingAllocation,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeAmounts:
          transactions.where((t) => !t.isExpense).map((t) => t.amount),
    );
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
    
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final isActiveToday = dailyAdjustmentDate == todayStr;
    
    int fund = remainingFund;
    int adj = 0;
    
    if (isActiveToday) {
      adj = dailyAdjustment;
      if (adj > 0) {
        fund = max(0, fund - adj);
      } else if (adj < 0) {
        fund = max(0, fund + adj.abs());
      }
    }
    
    final baseDaily = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: max(fund, 0),
      remainingDays: remainingDays,
    );
    
    final baseline = BudgetingEngine.applyBudgetMode(baseDailyBudget: baseDaily, mode: period!.mode);
    
    if (isActiveToday) {
      if (adj > 0) {
        return baseline + adj;
      } else if (adj < 0) {
        return max(0, baseline - adj.abs());
      }
    }
    return baseline;
  }

  DailyBudgetStatus get dailyStatus {
    return BudgetingEngine.getDailyBudgetStatus(todayExpense: todayExpense, dailySafeBudget: dailySafeBudget);
  }

  int get healthScore {
    var score = 78;
    final netBalance = remainingFund;
    
    // If there's no period, return a default safe score.
    if (period == null) return 80;

    final totalDays = max(1, period!.endDate.difference(period!.startDate).inDays + 1);
    
    final periodUsage = period!.flexibleFund <= 0 
        ? 0.0 : (totalExpense / period!.flexibleFund);
    
    final periodStatus = BudgetingEngine.getPeriodFundStatus(
      remainingFund: netBalance,
      remainingDays: remainingDays,
      flexibleFund: period!.flexibleFund,
      totalDays: totalDays,
    );

    if (netBalance < 0) score -= 28;
    
    // Only apply usage penalties/bonuses if they've actually started spending or are deep into the period
    if (totalExpense > 0) {
      if (periodUsage > 0.85) score -= 16;
      if (periodUsage < 0.55) score += 8;
    }
    
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
      await repo.resolveDailyBudgetAdjustment(today, period, transactions);
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
            final txId = 'autobill_${bill.id}_${today.year}_${today.month}';
            final txExists = transactions.any((t) => t.id == txId);

            bills[i] = bill.copyWith(
              isPaid: true,
              lastPaymentDate: today.toIso8601String(),
              lastAutoPayDate: today.toIso8601String(),
            );
            billsChanged = true;
            dataChanged = true;

            if (!txExists) {
              final tx = TransactionModel(
                id: txId,
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
      }
      if (billsChanged) {
        await localStorage.saveBills(bills.map((e) => e.toJson()).toList());
      }

      // 2. Process Automated Savings Allocations
      bool goalsChanged = false;
      for (int i = 0; i < savingGoals.length; i++) {
        final goal = savingGoals[i];
        if (goal.autoSaveAmount != null && goal.autoSaveAmount! > 0 && goal.autoSaveFrequency != null) {
          var lastSave = goal.lastAutoSaveDate;
          final todayZero = DateTime(today.year, today.month, today.day);
          
          bool goalChangedForThisItem = false;
          int accumulatedAmount = 0;
          
          if (lastSave == null) {
            // First time, save once for today
            final txId = 'autosave_${goal.id}_${todayZero.year}_${todayZero.month}_${todayZero.day}';
            final txExists = transactions.any((t) => t.id == txId);
            if (!txExists) {
              final tx = TransactionModel(
                id: txId,
                date: today,
                amount: goal.autoSaveAmount!,
                isExpense: true,
                category: 'Menabung',
                note: 'Tabungan otomatis: ${goal.name}',
              );
              await repo.addTransaction(tx);
              dataChanged = true;
            }
            lastSave = today;
            accumulatedAmount = goal.autoSaveAmount!;
            goalChangedForThisItem = true;
          } else {
            var tempDate = DateTime(lastSave.year, lastSave.month, lastSave.day);
            while (true) {
              // Calculate next save date
              if (goal.autoSaveFrequency == 'daily') {
                tempDate = tempDate.add(const Duration(days: 1));
              } else if (goal.autoSaveFrequency == 'weekly') {
                tempDate = tempDate.add(const Duration(days: 7));
              } else if (goal.autoSaveFrequency == 'monthly') {
                tempDate = DateTime(tempDate.year, tempDate.month + 1, tempDate.day);
              } else {
                break;
              }
              
              if (tempDate.isAfter(todayZero)) {
                break;
              }
              
              final txId = 'autosave_${goal.id}_${tempDate.year}_${tempDate.month}_${tempDate.day}';
              final txExists = transactions.any((t) => t.id == txId);
              if (!txExists) {
                final tx = TransactionModel(
                  id: txId,
                  date: tempDate,
                  amount: goal.autoSaveAmount!,
                  isExpense: true,
                  category: 'Menabung',
                  note: 'Tabungan otomatis: ${goal.name}',
                );
                await repo.addTransaction(tx);
                dataChanged = true;
              }
              lastSave = tempDate;
              accumulatedAmount += goal.autoSaveAmount!;
              goalChangedForThisItem = true;
            }
          }
          
          if (goalChangedForThisItem) {
            savingGoals[i] = goal.copyWith(
              currentAmount: goal.currentAmount + accumulatedAmount,
              lastAutoSaveDate: lastSave,
            );
            goalsChanged = true;
            dataChanged = true;
          }
        }
      }
      if (goalsChanged) {
        await repo.saveAllSavingGoals(savingGoals);
      }

      // 3. Process Recurring Transactions
      List<RecurringTransaction> recurringItems = await repo.loadRecurringTransactions();
      bool recurringChanged = false;
      for (int i = 0; i < recurringItems.length; i++) {
        var item = recurringItems[i];
        var currentDueDate = item.nextDueDate;
        final todayZero = DateTime(today.year, today.month, today.day);
        
        bool itemChanged = false;
        while (true) {
          final dueZero = DateTime(currentDueDate.year, currentDueDate.month, currentDueDate.day);
          if (dueZero.isAfter(todayZero)) {
            break;
          }
          
          final txId = 'recurring_${item.id}_${dueZero.year}_${dueZero.month}_${dueZero.day}';
          final txExists = transactions.any((t) => t.id == txId);
          if (!txExists) {
            final tx = TransactionModel(
              id: txId,
              date: dueZero,
              amount: item.amount,
              isExpense: item.isExpense,
              category: item.categoryName,
              note: '⚙️ Otomatis: ${item.note ?? item.categoryName}',
            );
            await repo.addTransaction(tx);
            dataChanged = true;
          }
          
          currentDueDate = item.copyWith(nextDueDate: currentDueDate).computeNextDueDate();
          itemChanged = true;
        }
        
        if (itemChanged) {
          recurringItems[i] = item.copyWith(
            lastExecutedDate: today,
            nextDueDate: currentDueDate,
          );
          recurringChanged = true;
        }
      }
      if (recurringChanged) {
        await repo.saveAllRecurringTransactions(recurringItems);
      }

      // If transactions or saving goals were updated, reload them!
      if (dataChanged) {
        transactions = await repo.loadTransactions();
        savingGoals = await repo.loadSavingGoals();
        savingGoal = await repo.loadSavingGoal();
      }
    }

    var loggingStreak = 0;
    var savingStreak = 0;
    var eveningClosedToday = false;
    String? yesterdayInsight;
    var weeklyInsightLines = <String>[];
    List<DailyClosing> closings = [];
    List<DailyHabitLog> habitLogs = [];

    if (period != null) {
      closings = await repo.loadDailyClosings();
      habitLogs = await repo.loadHabitLogs();
      final today = DateTime.now();
      await repo.saveHabitLog(
        HabitService.upsertLog(habitLogs, today, morningCheckDone: true),
      );
      habitLogs = await repo.loadHabitLogs();

      loggingStreak = HabitService.computeLoggingStreak(
        transactions,
        closings,
        habitLogs,
      );
      final tempState = DashboardState(
        period: period,
        transactions: transactions,
      );
      savingStreak = HabitService.computeSavingStreak(
        transactions: transactions,
        dailySafeBudget: tempState.dailySafeBudget,
      );
      eveningClosedToday = HabitService.isEveningClosedToday(closings, habitLogs);
      yesterdayInsight = HabitService.yesterdayCarrySummary(closings);
      weeklyInsightLines = HabitService.buildWeeklyInsights(
        transactions: transactions,
        averageDailySafeBudget: HabitService.averageDailySafe(
          remainingFund: tempState.remainingFund,
          remainingDays: tempState.remainingDays,
          mode: period.mode,
        ),
      ).lines;
    }

    // 4. Check & award achievements
    final existingAchievements = await repo.loadAchievements();
    final achievementResult = AchievementService.checkAndAward(
      current: existingAchievements,
      transactions: transactions,
      closings: closings,
      loggingStreak: loggingStreak,
      savingStreak: savingStreak,
      savingGoals: savingGoals,
    );
    if (achievementResult.newlyEarned.isNotEmpty) {
      await repo.saveAchievements(achievementResult.all);
      for (final ach in achievementResult.newlyEarned) {
        await repo.addInAppNotification(
          InAppNotification(
            id: '${DateTime.now().microsecondsSinceEpoch}_${ach.id}',
            title: 'Lencana Baru: ${ach.title}',
            message: 'Kamu berhasil menyelesaikan misi: ${ach.description}!',
            date: DateTime.now(),
            type: 'achievement',
          ),
        );
      }
    }

    final dailyAdjustment = await repo.getDailyBudgetAdjustment();
    final dailyAdjustmentDate = await repo.getDailyBudgetAdjustmentDate();
    final xp = await repo.getXp();
    final level = (xp ~/ 100) + 1;
    final notifications = await repo.loadInAppNotifications();
    notifications.sort((a, b) => b.date.compareTo(a.date));

    state = state.copyWith(
      period: period,
      transactions: transactions,
      savingGoal: savingGoal,
      savingGoals: savingGoals,
      userSettings: userSettings,
      isLoading: false,
      loggingStreak: loggingStreak,
      savingStreak: savingStreak,
      eveningClosedToday: eveningClosedToday,
      yesterdayInsight: yesterdayInsight,
      weeklyInsightLines: weeklyInsightLines,
      achievements: achievementResult.all,
      newlyEarnedAchievements: achievementResult.newlyEarned,
      dailyAdjustment: dailyAdjustment,
      dailyAdjustmentDate: dailyAdjustmentDate,
      userXp: xp,
      userLevel: level,
      inAppNotifications: notifications,
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

    await addXp(20);

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

    await addXp(20);

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
    await addXp(10);
    await loadData();

    final isOver = state.todayExpense > state.dailySafeBudget;
    if (isOver && !wasOver && transaction.isExpense) {
      await repo.addInAppNotification(
        InAppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: 'Jatah Harian Terlampaui 🚨',
          message: 'Pengeluaran hari ini sudah melewati jatah aman harianmu. Rem dulu belanjanya ya!',
          date: DateTime.now(),
          type: 'alert',
        ),
      );
      await loadData();
      if (!_hasPlayedWarningThisSession) {
        _hasPlayedWarningThisSession = true;
        _playSound(NataSoundPlayer.playWarning);
      }
    } else {
      _playSound(NataSoundPlayer.playSuccess);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final repo = _ref.read(budgetRepositoryProvider);
    await repo.updateTransaction(transaction);
    await loadData();
    _playSound(NataSoundPlayer.playSuccess);
  }

  Future<void> deleteTransaction(String id) async {
    final repo = _ref.read(budgetRepositoryProvider);
    await repo.deleteTransaction(id);
    
    await loadData();
    _playSound(NataSoundPlayer.playDelete);
  }

  Future<void> addXp(int amount) async {
    final repo = _ref.read(budgetRepositoryProvider);
    final currentXp = await repo.getXp();
    final newXp = currentXp + amount;
    await repo.saveXp(newXp);
    
    final currentLevel = (currentXp ~/ 100) + 1;
    final newLevel = (newXp ~/ 100) + 1;
    
    if (newLevel > currentLevel) {
      final levelUpNotif = InAppNotification(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: 'Naik Level! 🌟 Level $newLevel',
        message: 'Selamat! Finansialmu semakin terarah. Kamu naik ke level baru!',
        date: DateTime.now(),
        type: 'level',
      );
      await repo.addInAppNotification(levelUpNotif);
      _playSound(NataSoundPlayer.playAchievement);
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final repo = _ref.read(budgetRepositoryProvider);
    await repo.markNotificationsAsRead();
    await loadData();
  }

  void clearNewlyEarnedAchievements() {
    state = state.copyWith(newlyEarnedAchievements: const []);
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
      final totalDays = max(1, period.endDate.difference(period.startDate).inDays + 1);
      
      final periodStatus = BudgetingEngine.getPeriodFundStatus(
        remainingFund: remainingFund,
        remainingDays: remainingDays,
        flexibleFund: period.flexibleFund,
        totalDays: totalDays,
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
