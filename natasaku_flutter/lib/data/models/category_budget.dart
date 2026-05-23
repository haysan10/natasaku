class CategoryBudget {
  const CategoryBudget({
    required this.id,
    required this.category,
    required this.limitAmount,
    required this.emoji,
    this.colorHex,
  });

  final String id;
  final String category;
  final double limitAmount;
  final String emoji;
  final String? colorHex;

  CategoryBudget copyWith({
    String? id,
    String? category,
    double? limitAmount,
    String? emoji,
    String? colorHex,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'limitAmount': limitAmount,
        'emoji': emoji,
        'colorHex': colorHex,
      };

  factory CategoryBudget.fromMap(Map<String, dynamic> map) => CategoryBudget(
        id: map['id'] as String,
        category: map['category'] as String,
        limitAmount: (map['limitAmount'] as num).toDouble(),
        emoji: map['emoji'] as String? ?? '📦',
        colorHex: map['colorHex'] as String?,
      );
}
