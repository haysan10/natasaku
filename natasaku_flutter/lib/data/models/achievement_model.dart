/// A badge or milestone that the user can earn through consistent usage.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.earnedAt,
    this.isEarned = false,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime? earnedAt;
  final bool isEarned;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    DateTime? earnedAt,
    bool? isEarned,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      earnedAt: earnedAt ?? this.earnedAt,
      isEarned: isEarned ?? this.isEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'earnedAt': earnedAt?.toIso8601String(),
      'isEarned': isEarned,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      earnedAt: json['earnedAt'] == null
          ? null
          : DateTime.tryParse(json['earnedAt'] as String),
      isEarned: json['isEarned'] as bool? ?? false,
    );
  }
}

/// All achievable badges in NataSaku.
class AchievementDefinitions {
  static const List<Achievement> all = [
    Achievement(
      id: 'first_expense',
      title: 'Langkah Pertama! 🎉',
      description: 'Berhasil mencatat pengeluaran pertamamu',
      emoji: '🎉',
    ),
    Achievement(
      id: 'streak_3',
      title: '3 Hari Konsisten',
      description: 'Mencatat pengeluaran 3 hari berturut-turut',
      emoji: '⚡',
    ),
    Achievement(
      id: 'streak_7',
      title: '7 Hari On Fire! 🔥',
      description: 'Seminggu penuh konsisten mencatat keuangan',
      emoji: '🔥',
    ),
    Achievement(
      id: 'streak_14',
      title: '2 Minggu Kuat',
      description: 'Dua minggu tanpa putus — kamu luar biasa!',
      emoji: '💪',
    ),
    Achievement(
      id: 'streak_30',
      title: 'Master Konsisten! 🏆',
      description: 'Satu bulan penuh mencatat setiap hari',
      emoji: '🏆',
    ),
    Achievement(
      id: 'first_closing',
      title: 'Penutupan Pertama',
      description: 'Melakukan daily closing untuk pertama kali',
      emoji: '🌙',
    ),
    Achievement(
      id: 'saving_100k',
      title: 'Penabung Pemula',
      description: 'Tabungan celengan mencapai Rp100.000',
      emoji: '🐷',
    ),
    Achievement(
      id: 'saving_500k',
      title: 'Celengan Setengah Juta',
      description: 'Tabungan celengan mencapai Rp500.000',
      emoji: '💰',
    ),
    Achievement(
      id: 'saving_1m',
      title: 'Jutawan Celengan! 💎',
      description: 'Tabungan celengan menembus Rp1.000.000',
      emoji: '💎',
    ),
    Achievement(
      id: 'under_budget_7',
      title: 'Hemat 7 Hari',
      description: '7 hari berturut-turut belanja di bawah jatah harian',
      emoji: '🌟',
    ),
    Achievement(
      id: 'under_budget_14',
      title: 'Si Paling Hemat',
      description: '14 hari berturut-turut di bawah budget — incredible!',
      emoji: '👑',
    ),
  ];
}
