import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/routing/app_router.dart';
import '../../core/services/currency_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/achievement_model.dart';

class DailyRitualCard extends StatelessWidget {
  const DailyRitualCard({
    super.key,
    required this.remainingBudgetToday,
    required this.eveningClosedToday,
    required this.loggingStreak,
    required this.savingStreak,
    this.yesterdayInsight,
    required this.onLogExpense,
    this.achievements = const [],
  });

  final int remainingBudgetToday;
  final bool eveningClosedToday;
  final int loggingStreak;
  final int savingStreak;
  final String? yesterdayInsight;
  final VoidCallback onLogExpense;
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final isEvening = hour >= 18;

    // Get recently earned achievements (last 5)
    final earnedBadges = achievements
        .where((a) => a.isEarned)
        .toList()
      ..sort((a, b) => (b.earnedAt ?? DateTime(2000))
          .compareTo(a.earnedAt ?? DateTime(2000)));
    final recentBadges = earnedBadges.take(5).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                isEvening
                    ? PhosphorIconsRegular.moonStars
                    : PhosphorIconsRegular.sun,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEvening ? 'Ritual Malam' : 'Ritual Pagi',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (loggingStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: loggingStreak >= 7
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.primarySoft.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loggingStreak >= 3)
                        Text(
                          loggingStreak >= 7 ? '🔥' : '⚡',
                          style: const TextStyle(fontSize: 12),
                        ).animate(
                          onPlay: (c) => c.repeat(),
                        ).shimmer(
                          duration: 1500.ms,
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      if (loggingStreak >= 3) const SizedBox(width: 4),
                      Text(
                        '$loggingStreak hari',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: loggingStreak >= 7
                              ? AppColors.accent
                              : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (yesterdayInsight != null) ...[
            const SizedBox(height: 10),
            Text(
              yesterdayInsight!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],

          // Achievement Badges Row
          if (recentBadges.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: recentBadges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final badge = recentBadges[index];
                  return Tooltip(
                    message: badge.title,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(badge.emoji,
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            badge.title.replaceAll(RegExp(r'\s*[🔥🏆💎💪⚡🎉🌙🐷💰🌟👑]+\s*'), '').trim(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fade(delay: (index * 100).ms)
                      .scale(begin: const Offset(0.8, 0.8));
                },
              ),
            ),
          ],

          const SizedBox(height: 12),
          if (!isEvening) ...[
            Text(
              'Sisa jatah hari ini: ${CurrencyService.formatRupiah(remainingBudgetToday)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onLogExpense();
                },
                icon: const PhosphorIcon(PhosphorIconsRegular.plus, size: 18),
                label: const Text('Catat pengeluaran'),
              ),
            ),
          ] else if (!eveningClosedToday) ...[
            Text(
              'Tutup hari ini supaya jatah besok lebih akurat.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push(AppRouter.dailyClosing);
                },
                icon: const PhosphorIcon(PhosphorIconsRegular.checkCircle, size: 18),
                label: const Text('Penutupan hari'),
              ),
            ),
          ] else ...[
            Row(
              children: [
                const PhosphorIcon(
                  PhosphorIconsFill.checkCircle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hari ini sudah ditutup. Besok kita mulai segar lagi.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          if (savingStreak > 0) ...[
            const SizedBox(height: 10),
            Text(
              'Streak hemat: $savingStreak hari belanja di bawah jatah.${savingStreak >= 7 ? ' 🌟' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
