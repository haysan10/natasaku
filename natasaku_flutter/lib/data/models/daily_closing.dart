class DailyClosing {
  const DailyClosing({
    required this.date,
    required this.finalExpense,
    required this.carryOver,
    this.note,
  });

  final DateTime date;
  final double finalExpense;
  final double carryOver;
  final String? note;
}
