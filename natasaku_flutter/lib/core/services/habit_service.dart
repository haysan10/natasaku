import '../../data/models/budget_mode.dart';
import '../../data/models/daily_closing.dart';
import '../../data/models/daily_habit_log.dart';
import '../../data/models/transaction_model.dart';
import '../../features/budgeting/budgeting_engine.dart';
import 'currency_service.dart';

class WeeklyInsight {
  const WeeklyInsight({
    required this.lines,
  });

  final List<String> lines;
}

class HabitStreaks {
  const HabitStreaks({
    required this.loggingStreak,
    required this.savingStreak,
  });

  final int loggingStreak;
  final int savingStreak;
}

class HabitService {
  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static Set<DateTime> _activeDays(
    List<TransactionModel> transactions,
    List<DailyClosing> closings,
    List<DailyHabitLog> habitLogs,
  ) {
    final days = <DateTime>{};
    for (final tx in transactions) {
      days.add(_dayOnly(tx.date));
    }
    for (final c in closings) {
      days.add(_dayOnly(c.date));
    }
    for (final log in habitLogs) {
      if (log.morningCheckDone || log.eveningCloseDone) {
        days.add(log.dateOnly);
      }
    }
    return days;
  }

  static int computeLoggingStreak(
    List<TransactionModel> transactions,
    List<DailyClosing> closings,
    List<DailyHabitLog> habitLogs, {
    DateTime? today,
  }) {
    final now = _dayOnly(today ?? DateTime.now());
    final active = _activeDays(transactions, closings, habitLogs);
    var streak = 0;
    var cursor = now;
    while (active.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int computeSavingStreak({
    required List<TransactionModel> transactions,
    required int dailySafeBudget,
    DateTime? today,
  }) {
    if (dailySafeBudget <= 0) return 0;
    final now = _dayOnly(today ?? DateTime.now());
    var cursor = now;
    final todayExpense = transactions
        .where((t) => t.isExpense && _isSameDay(t.date, cursor))
        .fold(0, (a, b) => a + b.amount);
    if (todayExpense == 0) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (!cursor.isBefore(now.subtract(const Duration(days: 90)))) {
      final dayExpense = transactions
          .where((t) => t.isExpense && _isSameDay(t.date, cursor))
          .fold(0, (a, b) => a + b.amount);
      if (dayExpense == 0 || dayExpense > dailySafeBudget) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static bool isEveningClosedToday(
    List<DailyClosing> closings,
    List<DailyHabitLog> habitLogs, {
    DateTime? today,
  }) {
    final now = _dayOnly(today ?? DateTime.now());
    if (closings.any((c) => _isSameDay(c.date, now))) return true;
    return habitLogs.any((l) => l.dateOnly == now && l.eveningCloseDone);
  }

  static DailyHabitLog upsertLog(
    List<DailyHabitLog> logs,
    DateTime day, {
    bool? morningCheckDone,
    bool? eveningCloseDone,
  }) {
    final key = _dayOnly(day);
    final index = logs.indexWhere((l) => l.dateOnly == key);
    if (index >= 0) {
      return logs[index].copyWith(
        morningCheckDone: morningCheckDone,
        eveningCloseDone: eveningCloseDone,
      );
    }
    return DailyHabitLog(
      date: key,
      morningCheckDone: morningCheckDone ?? false,
      eveningCloseDone: eveningCloseDone ?? false,
    );
  }

  static List<DailyHabitLog> mergeLog(
    List<DailyHabitLog> logs,
    DailyHabitLog updated,
  ) {
    final key = updated.dateOnly;
    final next = [...logs]..removeWhere((l) => l.dateOnly == key);
    next.add(updated);
    next.sort((a, b) => b.dateOnly.compareTo(a.dateOnly));
    return next;
  }

  static String? yesterdayCarrySummary(
    List<DailyClosing> closings, {
    DateTime? today,
  }) {
    final now = _dayOnly(today ?? DateTime.now());
    final yesterday = now.subtract(const Duration(days: 1));
    DailyClosing? match;
    for (final c in closings) {
      if (_isSameDay(c.date, yesterday)) {
        match = c;
        break;
      }
    }
    if (match == null) return null;
    if (match.carryOver > 0) {
      return 'Kemarin hemat ${CurrencyService.formatRupiah(match.carryOver)} — jatah besok punya ruang lebih.';
    }
    if (match.carryOver < 0) {
      return 'Kemarin melewati jatah ${CurrencyService.formatRupiah(match.carryOver.abs())} — hari ini tetap bisa diatur pelan-pelan.';
    }
    return 'Kemarin seimbang dengan jatah — lanjutkan ritme yang sama hari ini.';
  }

  static WeeklyInsight buildWeeklyInsights({
    required List<TransactionModel> transactions,
    required int averageDailySafeBudget,
    DateTime? today,
  }) {
    final now = _dayOnly(today ?? DateTime.now());
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final expensesByDay = <DateTime, int>{};
    final categoryTotals = <String, int>{};

    for (final tx in transactions.where((t) => t.isExpense)) {
      final day = _dayOnly(tx.date);
      if (day.isBefore(weekStart) || day.isAfter(now)) continue;
      expensesByDay[day] = (expensesByDay[day] ?? 0) + tx.amount;
      final cat = tx.category ?? 'Lainnya';
      categoryTotals[cat] = (categoryTotals[cat] ?? 0) + tx.amount;
    }

    final lines = <String>[];

    if (expensesByDay.isEmpty) {
      lines.add('Minggu ini belum ada pengeluaran tercatat — mulai dari satu transaksi kecil.');
    } else {
      var thriftiestDay = expensesByDay.entries.first;
      var heaviestDay = expensesByDay.entries.first;
      for (final e in expensesByDay.entries) {
        if (e.value < thriftiestDay.value) thriftiestDay = e;
        if (e.value > heaviestDay.value) heaviestDay = e;
      }
      lines.add(
        'Hari paling hemat: ${thriftiestDay.key.day}/${thriftiestDay.key.month} (${CurrencyService.formatRupiah(thriftiestDay.value)}).',
      );
      if (heaviestDay.key != thriftiestDay.key) {
        lines.add(
          'Hari perlu perhatian: ${heaviestDay.key.day}/${heaviestDay.key.month} (${CurrencyService.formatRupiah(heaviestDay.value)}).',
        );
      }
    }

    if (categoryTotals.isNotEmpty) {
      final top = categoryTotals.entries.reduce(
        (a, b) => a.value >= b.value ? a : b,
      );
      lines.add('Kategori terbesar minggu ini: ${top.key} (${CurrencyService.formatRupiah(top.value)}).');
    }

    if (averageDailySafeBudget > 0 && expensesByDay.isNotEmpty) {
      final avgSpend =
          expensesByDay.values.fold(0, (a, b) => a + b) ~/ expensesByDay.length;
      final diff = averageDailySafeBudget - avgSpend;
      if (diff >= 0) {
        lines.add(
          'Rata-rata belanja harian ${CurrencyService.formatRupiah(avgSpend)} — di bawah jatah aman ${CurrencyService.formatRupiah(averageDailySafeBudget)}.',
        );
      } else {
        lines.add(
          'Rata-rata belanja harian ${CurrencyService.formatRupiah(avgSpend)} — sedikit di atas jatah ${CurrencyService.formatRupiah(averageDailySafeBudget)}. Bisa disesuaikan pelan-pelan.',
        );
      }
    }

    return WeeklyInsight(lines: lines.take(3).toList());
  }

  static int averageDailySafe({
    required int remainingFund,
    required int remainingDays,
    required BudgetMode mode,
  }) {
    final base = BudgetingEngine.calculateDailySafeBudget(
      remainingFund: remainingFund,
      remainingDays: remainingDays,
    );
    return BudgetingEngine.applyBudgetMode(
      baseDailyBudget: base,
      mode: mode,
    );
  }
}
