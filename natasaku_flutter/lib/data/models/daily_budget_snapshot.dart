import 'budget_status.dart';

class DailyBudgetSnapshot {
  const DailyBudgetSnapshot({
    required this.date,
    required this.dailySafeBudget,
    required this.todayExpense,
    required this.usageRatio,
    required this.status,
  });

  final DateTime date;
  final int dailySafeBudget;
  final int todayExpense;
  final double usageRatio;
  final DailyBudgetStatus status;
}
