class SavingGoal {
  const SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    this.autoSaveAmount,
    this.autoSaveFrequency,
    this.lastAutoSaveDate,
  });

  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime? targetDate;
  final int? autoSaveAmount;
  final String? autoSaveFrequency; // 'daily', 'weekly', 'monthly'
  final DateTime? lastAutoSaveDate;

  SavingGoal copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? targetDate,
    int? autoSaveAmount,
    String? autoSaveFrequency,
    DateTime? lastAutoSaveDate,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      autoSaveAmount: autoSaveAmount ?? this.autoSaveAmount,
      autoSaveFrequency: autoSaveFrequency ?? this.autoSaveFrequency,
      lastAutoSaveDate: lastAutoSaveDate ?? this.lastAutoSaveDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate?.toIso8601String(),
      'autoSaveAmount': autoSaveAmount,
      'autoSaveFrequency': autoSaveFrequency,
      'lastAutoSaveDate': lastAutoSaveDate?.toIso8601String(),
    };
  }

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).round(),
      currentAmount: (json['currentAmount'] as num).round(),
      targetDate: json['targetDate'] == null
          ? null
          : DateTime.tryParse(json['targetDate'] as String),
      autoSaveAmount: json['autoSaveAmount'] == null
          ? null
          : (json['autoSaveAmount'] as num).round(),
      autoSaveFrequency: json['autoSaveFrequency'] as String?,
      lastAutoSaveDate: json['lastAutoSaveDate'] == null
          ? null
          : DateTime.tryParse(json['lastAutoSaveDate'] as String),
    );
  }
}
