import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/data/datasources/local/local_storage.dart';
import 'package:natasaku/data/models/budget_period.dart';
import 'package:natasaku/data/models/daily_closing.dart';
import 'package:natasaku/data/models/saving_goal.dart';
import 'package:natasaku/data/models/transaction_model.dart';
import 'package:natasaku/data/models/user_settings.dart';
import 'package:natasaku/data/models/debt_model.dart';
import 'package:natasaku/data/models/in_app_notification.dart';
import 'package:natasaku/data/repositories/budget_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  late BudgetRepository repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = BudgetRepository(LocalStorage());
  });

  test('save and load period', () async {
    final period = BudgetPeriod(
      id: 'p1',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 30),
      flexibleFund: 1500000,
    );

    await repository.savePeriod(period);
    final loaded = await repository.loadPeriod();

    expect(loaded, isNotNull);
    expect(loaded!.id, 'p1');
    expect(loaded.flexibleFund, 1500000);
  });

  test('add transaction and daily closing persisted', () async {
    await repository.addTransaction(
      TransactionModel(
        id: 't1',
        date: DateTime(2026, 5, 11),
        amount: 12000,
        isExpense: true,
      ),
    );

    await repository.addDailyClosing(
      DailyClosing(
        date: DateTime(2026, 5, 11),
        finalExpense: 12000,
        carryOver: -2000,
        note: 'test',
      ),
    );

    final txs = await repository.loadTransactions();
    final closings = await repository.loadDailyClosings();

    expect(txs.length, 1);
    expect(txs.first.amount, 12000);
    expect(closings.length, 1);
    expect(closings.first.finalExpense, 12000);
  });

  test('update and delete transaction keeps existing transaction data safe',
      () async {
    await repository.addTransaction(
      TransactionModel(
        id: 't1',
        date: DateTime(2026, 5, 11),
        amount: 12000,
        isExpense: true,
        note: 'lama',
        category: 'Makan',
      ),
    );
    await repository.addTransaction(
      TransactionModel(
        id: 't2',
        date: DateTime(2026, 5, 12),
        amount: 45000,
        isExpense: true,
        category: 'Transport',
      ),
    );

    await repository.updateTransaction(
      TransactionModel(
        id: 't1',
        date: DateTime(2026, 5, 13),
        amount: 18000,
        isExpense: false,
        note: 'baru',
        category: 'Pemasukan',
      ),
    );
    await repository.deleteTransaction('t2');

    final txs = await repository.loadTransactions();

    expect(txs.length, 1);
    expect(txs.single.id, 't1');
    expect(txs.single.amount, 18000);
    expect(txs.single.isExpense, isFalse);
    expect(txs.single.note, 'baru');
    expect(txs.single.category, 'Pemasukan');
  });

  test('save load and clear saving goal', () async {
    final goal = SavingGoal(
      id: 'goal-1',
      name: 'Dana Darurat',
      targetAmount: 2500000,
      currentAmount: 300000,
      targetDate: DateTime(2026, 12, 31),
    );

    await repository.saveSavingGoal(goal);
    final loaded = await repository.loadSavingGoal();

    expect(loaded, isNotNull);
    expect(loaded!.name, 'Dana Darurat');
    expect(loaded.targetAmount, 2500000);
    expect(loaded.currentAmount, 300000);
    expect(loaded.targetDate, DateTime(2026, 12, 31));

    await repository.clearSavingGoal();
    expect(await repository.loadSavingGoal(), isNull);
  });

  test('save and load user settings keeps quick tools toggle', () async {
    const settings = UserSettings(
      dailyReminderEnabled: true,
      dailyReminderTime: '21:30',
      quickToolsNotificationEnabled: false,
      autoSavingEnabled: false,
      themeMode: ThemeMode.dark,
    );

    await repository.saveUserSettings(settings);
    final loaded = await repository.loadUserSettings();

    expect(loaded.dailyReminderEnabled, true);
    expect(loaded.dailyReminderTime, '21:30');
    expect(loaded.quickToolsNotificationEnabled, false);
    expect(loaded.autoSavingEnabled, false);
    expect(loaded.themeMode, ThemeMode.dark);
  });

  test('transaction preserves isNeed property', () async {
    await repository.addTransaction(
      TransactionModel(
        id: 't-need',
        date: DateTime(2026, 5, 11),
        amount: 25000,
        isExpense: true,
        category: 'Makan',
        isNeed: true,
      ),
    );
    await repository.addTransaction(
      TransactionModel(
        id: 't-want',
        date: DateTime(2026, 5, 11),
        amount: 15000,
        isExpense: true,
        category: 'Hiburan',
        isNeed: false,
      ),
    );

    final txs = await repository.loadTransactions();
    expect(txs.length, 2);
    expect(txs.firstWhere((t) => t.id == 't-need').isNeed, isTrue);
    expect(txs.firstWhere((t) => t.id == 't-want').isNeed, isFalse);
  });

  test('save and load XP points', () async {
    expect(await repository.getXp(), 0);
    await repository.saveXp(120);
    expect(await repository.getXp(), 120);
  });

  test('in-app notifications CRUD flow', () async {
    final notif = InAppNotification(
      id: 'n1',
      title: 'Level Up',
      message: 'Kamu naik level!',
      date: DateTime(2026, 5, 11),
      type: 'level',
      isRead: false,
    );

    await repository.addInAppNotification(notif);
    final loaded = await repository.loadInAppNotifications();
    expect(loaded.length, 1);
    expect(loaded.first.id, 'n1');
    expect(loaded.first.isRead, isFalse);

    await repository.markNotificationsAsRead();
    final updated = await repository.loadInAppNotifications();
    expect(updated.first.isRead, isTrue);
  });

  test('debts tracking CRUD flow', () async {
    final debt = DebtModel(
      id: 'd1',
      name: 'John Doe',
      amount: 50000,
      isIoweThem: true,
      dueDate: DateTime(2026, 6, 1),
      note: 'Cicilan barang',
    );

    await repository.upsertDebt(debt);
    final loaded = await repository.loadDebts();
    expect(loaded.length, 1);
    expect(loaded.first.name, 'John Doe');
    expect(loaded.first.isIoweThem, isTrue);

    await repository.upsertDebt(debt.copyWith(isPaid: true));
    final updated = await repository.loadDebts();
    expect(updated.first.isPaid, isTrue);

    await repository.deleteDebt('d1');
    expect(await repository.loadDebts(), isEmpty);
  });
}
