import 'budget_mode.dart';

class BudgetPeriod {
  const BudgetPeriod({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.flexibleFund,
    this.fixedExpenses = 0,
    this.monthlySavingAllocation = 0,
    this.mode = BudgetMode.normal,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double flexibleFund;
  final double fixedExpenses;
  final double monthlySavingAllocation;
  final BudgetMode mode;
}
