import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/repositories/budget_repository.dart';
import '../dashboard/dashboard_page.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  bool _loading = true;
  bool _hasPeriod = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final period = await _repo.loadPeriod();
    if (!mounted) return;
    setState(() {
      _hasPeriod = period != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasPeriod) {
      return const DashboardPage();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/branding/logo-natasaku-mark.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Selamat datang di NataSaku',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ucapkan selamat tinggal pada stres mengatur uang. NataSaku mengubah gaji bulananmu menjadi jatah belanja harian yang aman dan bebas rasa bersalah.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 40),
                    const _BenefitTile(
                      number: '1',
                      title: 'Batas Aman Harian',
                      subtitle:
                          'Langsung tahu berapa yang bisa kamu belanjakan hari ini tanpa takut kehabisan uang di akhir bulan.',
                    ),
                    const _BenefitTile(
                      number: '2',
                      title: 'Catat Tanpa Ribet',
                      subtitle:
                          'Cukup ketik nominal di notifikasi atau widget, tak perlu buka aplikasi tiap jajan.',
                    ),
                    const _BenefitTile(
                      number: '3',
                      title: 'Bebas Menghakimi',
                      subtitle:
                          'Tidak ada grafik rumit atau ceramah. Hanya sisa jatah hari ini dan besok.',
                    ),
                    const SizedBox(height: 48),
                    FilledButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.setup)
                              .then((_) => _load()),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text('Mulai Atur Uang (30 detik)'),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Semua data disimpan di HP-mu. 100% Privat.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
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

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
