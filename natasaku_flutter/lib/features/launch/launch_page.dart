import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/repository_providers.dart';

/// Returns true if user has already completed setup (budget period exists in storage).
final appInitializationProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(budgetRepositoryProvider);
  // Optional: add a slight delay for splash screen aesthetic
  await Future.delayed(const Duration(milliseconds: 1500));
  final period = await repo.loadPeriod();
  return period != null; // true = sudah setup, langsung ke dashboard
});

class LaunchPage extends ConsumerStatefulWidget {
  const LaunchPage({super.key});

  @override
  ConsumerState<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends ConsumerState<LaunchPage> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playSplashSound();
  }

  Future<void> _playSplashSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/splash.wav'));
    } catch (e) {
      debugPrint('Could not play splash sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initFuture = ref.watch(appInitializationProvider);

    return Scaffold(
      body: initFuture.when(
        loading: () => const _PremiumLoadingView(),
        error: (error, stack) => _ErrorView(
          onRetry: () {
            ref.invalidate(appInitializationProvider);
            _playSplashSound();
          },
        ),
        data: (hasSetup) {
          if (hasSetup) {
            // If already setup, ideally we redirect in GoRouter, but for now just show a fallback or route
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRouter.dashboard);
            });
            // Show loading view while redirecting
            return const _PremiumLoadingView();
          }
          return const _PremiumOnboardingView();
        },
      ),
    );
  }
}

class _PremiumLoadingView extends StatelessWidget {
  const _PremiumLoadingView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient background glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scaleXY(begin: 0.8, end: 1.2, duration: 2.seconds, curve: Curves.easeInOut),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with glassmorphic container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Image.asset(
                  'assets/branding/logo-natasaku-mark.png',
                  width: 90,
                  height: 90,
                ),
              )
              .animate()
              .scaleXY(begin: 0.5, end: 1.0, curve: Curves.easeOutBack, duration: 800.ms)
              .fadeIn(duration: 800.ms),
              
              const SizedBox(height: 32),
              
              // App Title
              Text(
                'NataSaku',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Keuangan Tenang, Hidup Senang',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ],
      ),
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
                            color: AppColors.primary.withOpacity(0.3),
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
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: FilledButton.icon(
                        onPressed: () => context.go(AppRouter.tour),
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
              color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
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

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.alert.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.alert,
                size: 56,
              ),
            ).animate().shake(duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Aplikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Terjadi kesalahan saat menginisialisasi database lokal NataSaku. Silakan coba lagi.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
