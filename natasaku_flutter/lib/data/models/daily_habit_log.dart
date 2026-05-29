class DailyHabitLog {
  const DailyHabitLog({
    required this.date,
    this.morningCheckDone = false,
    this.eveningCloseDone = false,
  });

  final DateTime date;
  final bool morningCheckDone;
  final bool eveningCloseDone;

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() => {
        'date': dateOnly.toIso8601String(),
        'morningCheckDone': morningCheckDone,
        'eveningCloseDone': eveningCloseDone,
      };

  factory DailyHabitLog.fromJson(Map<String, dynamic> json) {
    return DailyHabitLog(
      date: DateTime.parse(json['date'] as String),
      morningCheckDone: json['morningCheckDone'] as bool? ?? false,
      eveningCloseDone: json['eveningCloseDone'] as bool? ?? false,
    );
  }

  DailyHabitLog copyWith({
    bool? morningCheckDone,
    bool? eveningCloseDone,
  }) {
    return DailyHabitLog(
      date: date,
      morningCheckDone: morningCheckDone ?? this.morningCheckDone,
      eveningCloseDone: eveningCloseDone ?? this.eveningCloseDone,
    );
  }
}
