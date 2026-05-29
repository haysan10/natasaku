import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';

class LaunchPage extends ConsumerStatefulWidget {
  const LaunchPage({super.key});

  @override
  ConsumerState<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends ConsumerState<LaunchPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _PremiumOnboardingView(),
    );
  }
}

class _PremiumOnboardingView extends StatelessWidget {
  const _PremiumOnboardingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/branding/logo-natasaku-mark.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          color: Colors.white, // Masking white if transparent
                        ),
                      ),
                    ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 40),
                    
                    Text(
                      'Uang Anda,\nDalam Kendali.',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 40,
                        height: 1.1,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Ucapkan selamat tinggal pada stres mengatur uang. NataSaku mengubah gaji bulananmu menjadi jatah belanja harian yang aman dan bebas rasa bersalah.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.5,
                        fontSize: 16,
                      ),
                    ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 48),
                    
                    // Benefits list
                    const _PremiumBenefitTile(
                      icon: PhosphorIconsFill.shieldCheck,
                      title: 'Batas Aman Harian',
                      subtitle: 'Tahu persis sisa uang untuk hari ini tanpa takut kehabisan di akhir bulan.',
                    ).animate().fade(delay: 600.ms, duration: 600.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    
                    const _PremiumBenefitTile(
                      icon: PhosphorIconsFill.lightning,
                      title: 'Pencatatan Cepat',
                      subtitle: 'Catat pengeluaran langsung dari notifikasi tray atau widget homescreen.',
                    ).animate().fade(delay: 800.ms, duration: 600.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 48),
                    
                    // Call to Action
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => context.go(AppRouter.setup),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.rocket_launch_rounded),
                        label: const Text(
                          'MULAI PERJALANAN ANDA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 1000.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 24),
                    
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsFill.lockKey,
                            size: 14,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '100% Privat. Semua data disimpan di HP-mu.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 1200.ms, duration: 600.ms),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumBenefitTile extends StatelessWidget {
  const _PremiumBenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: PhosphorIcon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

