class DebtModel {
  const DebtModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.isIoweThem,
    this.note,
    this.dueDate,
    this.isPaid = false,
  });

  final String id;
  final String name;
  final int amount;
  final bool isIoweThem; // true: I owe them (utang), false: they owe me (piutang)
  final String? note;
  final DateTime? dueDate;
  final bool isPaid;

  DebtModel copyWith({
    String? id,
    String? name,
    int? amount,
    bool? isIoweThem,
    String? note,
    DateTime? dueDate,
    bool? isPaid,
  }) {
    return DebtModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isIoweThem: isIoweThem ?? this.isIoweThem,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'isIoweThem': isIoweThem,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).round(),
      isIoweThem: json['isIoweThem'] as bool? ?? true,
      note: json['note'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.tryParse(json['dueDate'] as String),
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }
}
