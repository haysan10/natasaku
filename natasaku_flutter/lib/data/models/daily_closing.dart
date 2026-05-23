class DailyClosing {
  const DailyClosing({
    required this.date,
    required this.finalExpense,
    required this.carryOver,
    this.note,
  });

  final DateTime date;
  final int finalExpense;
  final int carryOver;
  final String? note;
}
