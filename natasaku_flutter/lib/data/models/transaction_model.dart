class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.isExpense,
    this.note,
    this.category,
    this.photoPath,
    this.isNeed = true,
  });

  final String id;
  final DateTime date;
  final int amount;
  final bool isExpense;
  final String? note;
  final String? category;

  /// Local file path to an attached receipt/note photo.
  final String? photoPath;

  /// Indicates if this transaction is a Need (true) or Want (false).
  final bool isNeed;

  TransactionModel copyWith({
    String? id,
    DateTime? date,
    int? amount,
    bool? isExpense,
    String? note,
    String? category,
    String? photoPath,
    bool? isNeed,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      note: note ?? this.note,
      category: category ?? this.category,
      photoPath: photoPath ?? this.photoPath,
      isNeed: isNeed ?? this.isNeed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'isExpense': isExpense,
      'note': note,
      'category': category,
      'photoPath': photoPath,
      'isNeed': isNeed,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).round(),
      isExpense: json['isExpense'] as bool? ?? true,
      note: json['note'] as String?,
      category: json['category'] as String?,
      photoPath: json['photoPath'] as String?,
      isNeed: json['isNeed'] as bool? ?? true,
    );
  }
}
