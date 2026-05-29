import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/achievement_model.dart';

/// Shows a celebratory dialog when a new achievement is earned.
Future<void> showAchievementCelebration(
  BuildContext context,
  Achievement achievement,
) {
  HapticFeedback.heavyImpact();
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _AchievementDialog(achievement: achievement),
  );
}

class _AchievementDialog extends StatelessWidget {
  const _AchievementDialog({required this.achievement});
  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji burst
            Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 64),
            )
                .animate(onPlay: (c) => c.repeat(count: 1))
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shake(hz: 3, duration: 300.ms),

            const SizedBox(height: 16),

            // Stars decorations
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.accent,
                      size: 20 + (i == 1 ? 8 : 0),
                    ),
                  ),
              ],
            )
                .animate()
                .fade(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 20),

            // Title
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(delay: 200.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 8),

            // Description
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fade(delay: 350.ms),

            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Mantap! 🎉',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                .animate()
                .fade(delay: 400.ms)
                .slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }
}
