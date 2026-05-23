class BillModel {
  const BillModel({
    required this.id,
    required this.name,
    required this.amount,
    this.dueDate, // 1 to 31
    this.isPaid = false,
    this.isAutoPay = false,
    this.lastAutoPayDate,
    this.lastPaymentDate,
  });

  final String id;
  final String name;
  final int amount;
  final int? dueDate;
  final bool isPaid;
  final bool isAutoPay;
  final String? lastAutoPayDate;
  final String? lastPaymentDate;

  BillModel copyWith({
    String? id,
    String? name,
    int? amount,
    int? dueDate,
    bool? isPaid,
    bool? isAutoPay,
    String? lastAutoPayDate,
    String? lastPaymentDate,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      lastAutoPayDate: lastAutoPayDate ?? this.lastAutoPayDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDate': dueDate,
      'isPaid': isPaid,
      'isAutoPay': isAutoPay,
      'lastAutoPayDate': lastAutoPayDate,
      'lastPaymentDate': lastPaymentDate,
    };
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).round(),
      dueDate: json['dueDate'] as int?,
      isPaid: json['isPaid'] as bool? ?? false,
      isAutoPay: json['isAutoPay'] as bool? ?? false,
      lastAutoPayDate: json['lastAutoPayDate'] as String?,
      lastPaymentDate: json['lastPaymentDate'] as String?,
    );
  }
}
