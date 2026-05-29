import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/core/services/habit_service.dart';
import 'package:natasaku/data/models/transaction_model.dart';

void main() {
  test('computeLoggingStreak counts consecutive active days', () {
    final today = DateTime(2026, 5, 24);
    final transactions = [
      TransactionModel(
        id: '1',
        date: today,
        amount: 10000,
        isExpense: true,
      ),
      TransactionModel(
        id: '2',
        date: today.subtract(const Duration(days: 1)),
        amount: 5000,
        isExpense: true,
      ),
    ];

    final streak = HabitService.computeLoggingStreak(
      transactions,
      [],
      [],
      today: today,
    );

    expect(streak, 2);
  });

  test('buildWeeklyInsights returns up to three lines', () {
    final today = DateTime(2026, 5, 24);
    final transactions = [
      TransactionModel(
        id: '1',
        date: today,
        amount: 50000,
        isExpense: true,
        category: 'Makan',
      ),
    ];

    final insight = HabitService.buildWeeklyInsights(
      transactions: transactions,
      averageDailySafeBudget: 80000,
      today: today,
    );

    expect(insight.lines, isNotEmpty);
    expect(insight.lines.length, lessThanOrEqualTo(3));
  });
}
