import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../data/models/category_budget.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class CategoryBudgetState {
  final List<CategoryBudget> budgets;
  final bool isLoading;

  const CategoryBudgetState({
    this.budgets = const [],
    this.isLoading = true,
  });

  CategoryBudgetState copyWith({
    List<CategoryBudget>? budgets,
    bool? isLoading,
  }) {
    return CategoryBudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CategoryBudgetNotifier extends StateNotifier<CategoryBudgetState> {
  final Ref _ref;

  CategoryBudgetNotifier(this._ref) : super(const CategoryBudgetState()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(budgetRepositoryProvider);
    final list = await repo.loadCategoryBudgets();
    state = state.copyWith(budgets: list, isLoading: false);
  }

  Future<void> saveBudget(CategoryBudget budget) async {
    final repo = _ref.read(budgetRepositoryProvider);
    await repo.upsertCategoryBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    final repo = _ref.read(budgetRepositoryProvider);
    await repo.deleteCategoryBudget(id);
    await loadBudgets();
  }
}

final categoryBudgetProvider =
    StateNotifierProvider<CategoryBudgetNotifier, CategoryBudgetState>((ref) {
  return CategoryBudgetNotifier(ref);
});

// Helper provider to get detailed budget information including spent amounts
class CategoryBudgetDetail {
  final CategoryBudget budget;
  final double spent;
  
  const CategoryBudgetDetail({
    required this.budget,
    required this.spent,
  });

  double get remaining => (budget.limitAmount - spent).clamp(0.0, double.infinity);
  double get progress => budget.limitAmount > 0 ? (spent / budget.limitAmount).clamp(0.0, 1.0) : 0.0;
  bool get isExceeded => spent > budget.limitAmount;
  bool get isWarning => spent >= budget.limitAmount * 0.8 && spent <= budget.limitAmount;
}

final categoryBudgetDetailsProvider = Provider<List<CategoryBudgetDetail>>((ref) {
  final budgetState = ref.watch(categoryBudgetProvider);
  final dashboardState = ref.watch(dashboardProvider);

  if (budgetState.isLoading || dashboardState.isLoading) {
    return [];
  }

  final transactions = dashboardState.transactions;
  
  // Calculate spent per category (only expenses during current period, if period is set)
  final period = dashboardState.period;
  final filteredTransactions = period == null
      ? transactions
      : transactions.where((t) =>
          t.isExpense &&
          t.date.isAfter(period.startDate.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(period.endDate.add(const Duration(seconds: 1))));

  return budgetState.budgets.map((budget) {
    final spent = filteredTransactions
        .where((t) => t.category?.toLowerCase() == budget.category.toLowerCase())
        .fold(0.0, (sum, t) => sum + t.amount);

    return CategoryBudgetDetail(
      budget: budget,
      spent: spent,
    );
  }).toList();
});
