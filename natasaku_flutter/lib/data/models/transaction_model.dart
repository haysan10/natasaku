class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.isExpense,
    this.note,
    this.category,
  });

  final String id;
  final DateTime date;
  final double amount;
  final bool isExpense;
  final String? note;
  final String? category;
}
