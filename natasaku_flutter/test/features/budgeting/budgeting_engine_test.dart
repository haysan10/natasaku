import 'package:flutter_test/flutter_test.dart';
import 'package:natasaku/data/models/budget_mode.dart';
import 'package:natasaku/data/models/budget_status.dart';
import 'package:natasaku/features/budgeting/budgeting_engine.dart';

void main() {
  group('BudgetingEngine', () {
    test('calculateRemainingDays inclusive', () {
      final days = BudgetingEngine.calculateRemainingDays(
        today: DateTime(2026, 5, 11),
        periodEnd: DateTime(2026, 5, 20),
      );

      expect(days, 10);
    });

    test('calculateDailySafeBudget handles zero day', () {
      final result = BudgetingEngine.calculateDailySafeBudget(
        remainingFund: 500000,
        remainingDays: 0,
      );

      expect(result, 0);
    });

    test('calculateDailySafeBudget uses integer division and never returns negative money', () {
      expect(
        BudgetingEngine.calculateDailySafeBudget(
          remainingFund: 2400000,
          remainingDays: 30,
        ),
        80000,
      );

      expect(
        BudgetingEngine.calculateDailySafeBudget(
          remainingFund: -5000,
          remainingDays: 5,
        ),
        0,
      );
    });

    test('daily status mapping follows thresholds', () {
      expect(
        BudgetingEngine.getDailyBudgetStatus(
            todayExpense: 0, dailySafeBudget: 100000),
        DailyBudgetStatus.belumAdaPengeluaran,
      );

      expect(
        BudgetingEngine.getDailyBudgetStatus(
            todayExpense: 70000, dailySafeBudget: 100000),
        DailyBudgetStatus.aman,
      );

      expect(
        BudgetingEngine.getDailyBudgetStatus(
            todayExpense: 90000, dailySafeBudget: 100000),
        DailyBudgetStatus.mendekatiBatas,
      );

      expect(
        BudgetingEngine.getDailyBudgetStatus(
            todayExpense: 110000, dailySafeBudget: 100000),
        DailyBudgetStatus.melebihiSedikit,
      );

      expect(
        BudgetingEngine.getDailyBudgetStatus(
            todayExpense: 130000, dailySafeBudget: 100000),
        DailyBudgetStatus.boros,
      );
    });

    test('period status handles finished and empty fund', () {
      expect(
        BudgetingEngine.getPeriodFundStatus(
            remainingFund: 100000, remainingDays: 0),
        PeriodFundStatus.periodeSelesai,
      );

      expect(
        BudgetingEngine.getPeriodFundStatus(remainingFund: 0, remainingDays: 5),
        PeriodFundStatus.danaHabis,
      );
    });

    test('dynamic recommendation adapts to risk', () {
      final safe = BudgetingEngine.generateDynamicRecommendation(
        dailyStatus: DailyBudgetStatus.aman,
        periodStatus: PeriodFundStatus.aman,
      );
      final critical = BudgetingEngine.generateDynamicRecommendation(
        dailyStatus: DailyBudgetStatus.mendekatiBatas,
        periodStatus: PeriodFundStatus.kritis,
      );

      expect(safe.contains('aman') || safe.contains('Posisi aman'), true);
      expect(critical.contains('kritis') || critical.contains('Batasi'), true);
    });

    test('budget mode adjusts safe daily budget', () {
      expect(
        BudgetingEngine.applyBudgetMode(
          baseDailyBudget: 100000,
          mode: BudgetMode.normal,
        ),
        100000,
      );
      expect(
        BudgetingEngine.applyBudgetMode(
          baseDailyBudget: 100000,
          mode: BudgetMode.hemat,
        ),
        85000,
      );
      expect(
        BudgetingEngine.applyBudgetMode(
          baseDailyBudget: 100000,
          mode: BudgetMode.krisis,
        ),
        70000,
      );
    });
  });
}
