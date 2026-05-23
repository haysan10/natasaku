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
  final double dailySafeBudget;
  final double todayExpense;
  final double usageRatio;
  final DailyBudgetStatus status;
}
