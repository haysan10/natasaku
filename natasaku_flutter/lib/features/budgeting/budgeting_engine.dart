import '../../core/constants/app_constants.dart';
import '../../core/services/currency_service.dart';
import '../../data/models/budget_mode.dart';
import '../../data/models/budget_status.dart';

class BudgetingEngine {
  static int calculateRemainingDays({
    required DateTime today,
    required DateTime periodEnd,
  }) {
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(periodEnd.year, periodEnd.month, periodEnd.day);
    return end.difference(start).inDays + 1;
  }

  static int calculateDailySafeBudget({
    required int remainingFund,
    required int remainingDays,
  }) {
    if (remainingFund <= 0 || remainingDays <= 0) {
      return 0;
    }
    return remainingFund ~/ remainingDays;
  }

  static double calculateTodayBudgetUsage({
    required int todayExpense,
    required int dailySafeBudget,
  }) {
    if (todayExpense < 0 || dailySafeBudget <= 0) {
      return 0;
    }
    return todayExpense / dailySafeBudget;
  }

  static DailyBudgetStatus getDailyBudgetStatus({
    required int todayExpense,
    required int dailySafeBudget,
  }) {
    if (todayExpense <= 0) {
      return DailyBudgetStatus.belumAdaPengeluaran;
    }

    final usage = calculateTodayBudgetUsage(
      todayExpense: todayExpense,
      dailySafeBudget: dailySafeBudget,
    );

    if (usage <= AppConstants.warningThreshold) return DailyBudgetStatus.aman;
    if (usage <= 1) return DailyBudgetStatus.mendekatiBatas;
    if (usage <= AppConstants.exceedSlightlyThreshold) {
      return DailyBudgetStatus.melebihiSedikit;
    }
    return DailyBudgetStatus.boros;
  }

  static PeriodFundStatus getPeriodFundStatus({
    required int remainingFund,
    required int remainingDays,
  }) {
    if (remainingDays <= 0) return PeriodFundStatus.periodeSelesai;
    if (remainingFund <= 0) {
      return PeriodFundStatus.danaHabis;
    }

    final dailyBuffer = remainingFund ~/ remainingDays;
    if (dailyBuffer > 100000) return PeriodFundStatus.aman;
    if (dailyBuffer > 50000) return PeriodFundStatus.waspada;
    return PeriodFundStatus.kritis;
  }

  static int calculateTomorrowSafeBudget({
    required int remainingFundAfterToday,
    required int remainingDaysAfterToday,
  }) {
    return calculateDailySafeBudget(
      remainingFund: remainingFundAfterToday < 0 ? 0 : remainingFundAfterToday,
      remainingDays: remainingDaysAfterToday,
    );
  }

  static int predictEndingBalance({
    required int remainingFund,
    required int averageDailyExpense,
    required int remainingDays,
  }) {
    if (remainingFund <= 0 || averageDailyExpense <= 0) return 0;
    return remainingFund - (averageDailyExpense * remainingDays);
  }

  static DateTime? predictFundRunoutDate({
    required DateTime today,
    required int remainingFund,
    required int averageDailyExpense,
  }) {
    if (averageDailyExpense <= 0) return null;
    if (remainingFund <= 0) return today;

    final daysUntilRunout = remainingFund ~/ averageDailyExpense;
    return today.add(Duration(days: daysUntilRunout));
  }

  static String generateRecoveryPlan({
    required int remainingFund,
    required int remainingDays,
  }) {
    if (remainingDays <= 0) {
      return 'Periode selesai. Mulai setup periode baru agar budgeting kembali akurat.';
    }

    if (remainingFund <= 0) {
      return 'Dana fleksibel habis. Prioritaskan pengeluaran wajib dan tambah pemasukan bila memungkinkan.';
    }

    final safeBudget = calculateDailySafeBudget(
      remainingFund: remainingFund,
      remainingDays: remainingDays,
    );

    return 'Agar cukup sampai akhir periode, batasi pengeluaran sekitar ${formatRupiah(safeBudget)} per hari.';
  }

  static String formatRupiah(num value) => CurrencyService.formatRupiah(value);

  static int applyBudgetMode({
    required int baseDailyBudget,
    required BudgetMode mode,
  }) {
    if (baseDailyBudget <= 0) return 0;
    switch (mode) {
      case BudgetMode.normal:
        return baseDailyBudget;
      case BudgetMode.hemat:
        return (baseDailyBudget * 85) ~/ 100;
      case BudgetMode.krisis:
        return (baseDailyBudget * 70) ~/ 100;
    }
  }

  static String generateDynamicRecommendation({
    required DailyBudgetStatus dailyStatus,
    required PeriodFundStatus periodStatus,
  }) {
    if (periodStatus == PeriodFundStatus.danaHabis) {
      return 'Dana fleksibel habis. Tunda belanja non-prioritas dan fokus kebutuhan wajib.';
    }

    if (periodStatus == PeriodFundStatus.kritis) {
      return 'Posisi periode kritis. Batasi belanja hari ini agar tetap cukup sampai akhir periode.';
    }

    if (dailyStatus == DailyBudgetStatus.boros) {
      return 'Hari ini sudah melewati jatah. Kurangi pengeluaran opsional agar besok lebih aman.';
    }

    if (dailyStatus == DailyBudgetStatus.mendekatiBatas) {
      return 'Jatah hari ini hampir habis. Prioritaskan kebutuhan utama dulu.';
    }

    return 'Posisi aman. Tetap catat transaksi agar prediksi besok akurat.';
  }
}
