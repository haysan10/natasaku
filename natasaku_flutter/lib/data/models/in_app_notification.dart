class InAppNotification {
  const InAppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
    required this.type, // 'level', 'achievement', 'alert', 'info'
  });

  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;
  final String type;

  InAppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
    String? type,
  }) {
    return InAppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'info',
    );
  }
}
