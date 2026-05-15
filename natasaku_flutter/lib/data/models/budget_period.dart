import 'budget_mode.dart';

class BudgetPeriod {
  const BudgetPeriod({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.flexibleFund,
    this.mode = BudgetMode.normal,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double flexibleFund;
  final BudgetMode mode;
}
