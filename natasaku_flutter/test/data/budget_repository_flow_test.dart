import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku_flutter/data/datasources/local/local_storage.dart';
import 'package:natasaku_flutter/data/models/budget_period.dart';
import 'package:natasaku_flutter/data/models/daily_closing.dart';
import 'package:natasaku_flutter/data/models/saving_goal.dart';
import 'package:natasaku_flutter/data/models/transaction_model.dart';
import 'package:natasaku_flutter/data/models/user_settings.dart';
import 'package:natasaku_flutter/data/repositories/budget_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    );

    await repository.saveUserSettings(settings);
    final loaded = await repository.loadUserSettings();

    expect(loaded.dailyReminderEnabled, true);
    expect(loaded.dailyReminderTime, '21:30');
    expect(loaded.quickToolsNotificationEnabled, false);
    expect(loaded.autoSavingEnabled, false);
  });
}
