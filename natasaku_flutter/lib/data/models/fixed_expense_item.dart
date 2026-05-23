enum FixedExpenseCategory {
  sewakos,
  cicilanKendaraan,
  cicilanRumah,
  asuransi,
  internet,
  listrik,
  air,
  gas,
  streaming,
  gymKesehatan,
  sekolahKuliah,
  tabunganWajib,
  lainnya,
}

class FixedExpenseItem {
  const FixedExpenseItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.emoji,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int amount;
  final FixedExpenseCategory category;
  final String emoji;
  final bool isActive;

  static int totalOf(List<FixedExpenseItem> items) =>
      items.where((i) => i.isActive).fold(0, (sum, i) => sum + i.amount);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category.name,
    'emoji': emoji,
    'isActive': isActive,
  };

  factory FixedExpenseItem.fromJson(Map<String, dynamic> json) =>
      FixedExpenseItem(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: json['amount'] as int,
        category: FixedExpenseCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => FixedExpenseCategory.lainnya,
        ),
        emoji: json['emoji'] as String? ?? '📦',
        isActive: json['isActive'] as bool? ?? true,
      );
}
