import '../../data/models/achievement_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/daily_closing.dart';
import '../../data/models/saving_goal.dart';

/// Service that checks user progress and awards achievements.
class AchievementService {
  /// Evaluates all achievement conditions and returns the updated list.
  /// [newlyEarned] will contain IDs of achievements earned in this check.
  static ({List<Achievement> all, List<Achievement> newlyEarned}) checkAndAward({
    required List<Achievement> current,
    required List<TransactionModel> transactions,
    required List<DailyClosing> closings,
    required int loggingStreak,
    required int savingStreak,
    required List<SavingGoal> savingGoals,
  }) {
    // Build map of current earned state
    final earned = <String, Achievement>{};
    for (final a in current) {
      earned[a.id] = a;
    }

    final newlyEarned = <Achievement>[];
    final now = DateTime.now();

    for (final def in AchievementDefinitions.all) {
      // Skip already earned
      if (earned[def.id]?.isEarned == true) continue;

      final shouldEarn = _evaluateCondition(
        id: def.id,
        transactions: transactions,
        closings: closings,
        loggingStreak: loggingStreak,
        savingStreak: savingStreak,
        savingGoals: savingGoals,
      );

      if (shouldEarn) {
        final awarded = def.copyWith(isEarned: true, earnedAt: now);
        earned[def.id] = awarded;
        newlyEarned.add(awarded);
      }
    }

    // Build final list preserving all definitions
    final all = AchievementDefinitions.all.map((def) {
      return earned[def.id] ?? def;
    }).toList();

    return (all: all, newlyEarned: newlyEarned);
  }

  static bool _evaluateCondition({
    required String id,
    required List<TransactionModel> transactions,
    required List<DailyClosing> closings,
    required int loggingStreak,
    required int savingStreak,
    required List<SavingGoal> savingGoals,
  }) {
    switch (id) {
      case 'first_expense':
        return transactions.any((t) => t.isExpense);

      case 'streak_3':
        return loggingStreak >= 3;

      case 'streak_7':
        return loggingStreak >= 7;

      case 'streak_14':
        return loggingStreak >= 14;

      case 'streak_30':
        return loggingStreak >= 30;

      case 'first_closing':
        return closings.isNotEmpty;

      case 'saving_100k':
        return _totalSavings(savingGoals) >= 100000;

      case 'saving_500k':
        return _totalSavings(savingGoals) >= 500000;

      case 'saving_1m':
        return _totalSavings(savingGoals) >= 1000000;

      case 'under_budget_7':
        return savingStreak >= 7;

      case 'under_budget_14':
        return savingStreak >= 14;

      default:
        return false;
    }
  }

  static int _totalSavings(List<SavingGoal> goals) {
    if (goals.isEmpty) return 0;
    return goals.fold(0, (sum, g) => sum + g.currentAmount);
  }
}
