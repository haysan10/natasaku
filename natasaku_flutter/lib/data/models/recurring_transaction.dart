/// Model for a recurring (scheduled) transaction that auto-creates
/// TransactionModel entries on a daily, weekly, or monthly basis.
class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.categoryName,
    required this.amount,
    required this.isExpense,
    required this.frequency,
    required this.nextDueDate,
    this.note,
    this.lastExecutedDate,
    this.isActive = true,
  });

  final String id;
  final String categoryName;
  final int amount;
  final bool isExpense;
  final String? note;

  /// One of 'daily', 'weekly', 'monthly'.
  final String frequency;

  /// The next date this recurring transaction should fire.
  final DateTime nextDueDate;

  /// The last date this recurring transaction was auto-executed.
  final DateTime? lastExecutedDate;

  /// Whether this recurring entry is active.
  final bool isActive;

  RecurringTransaction copyWith({
    String? id,
    String? categoryName,
    int? amount,
    bool? isExpense,
    String? note,
    String? frequency,
    DateTime? nextDueDate,
    DateTime? lastExecutedDate,
    bool? isActive,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastExecutedDate: lastExecutedDate ?? this.lastExecutedDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'amount': amount,
      'isExpense': isExpense,
      'note': note,
      'frequency': frequency,
      'nextDueDate': nextDueDate.toIso8601String(),
      'lastExecutedDate': lastExecutedDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'] as String,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).round(),
      isExpense: json['isExpense'] as bool? ?? true,
      note: json['note'] as String?,
      frequency: json['frequency'] as String? ?? 'monthly',
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      lastExecutedDate: json['lastExecutedDate'] == null
          ? null
          : DateTime.tryParse(json['lastExecutedDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Computes the next due date after execution, based on [frequency].
  DateTime computeNextDueDate() {
    switch (frequency) {
      case 'daily':
        return DateTime(
          nextDueDate.year,
          nextDueDate.month,
          nextDueDate.day + 1,
        );
      case 'weekly':
        return DateTime(
          nextDueDate.year,
          nextDueDate.month,
          nextDueDate.day + 7,
        );
      case 'monthly':
        return DateTime(
          nextDueDate.year,
          nextDueDate.month + 1,
          nextDueDate.day,
        );
      default:
        return DateTime(
          nextDueDate.year,
          nextDueDate.month + 1,
          nextDueDate.day,
        );
    }
  }

  /// Whether this recurring transaction is due today or earlier.
  bool isDue(DateTime today) {
    if (!isActive) return false;
    final todayZero = DateTime(today.year, today.month, today.day);
    final dueZero = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );
    return !todayZero.isBefore(dueZero);
  }

  /// Human-readable frequency label in Indonesian.
  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      default:
        return frequency;
    }
  }
}
