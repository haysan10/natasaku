import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';
import '../../app/theme/app_theme.dart';
import '../../data/datasources/local/local_storage.dart';

class TourPage extends StatefulWidget {
  const TourPage({super.key});

  @override
  State<TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<TourPage> {
  final PageController _controller = PageController();
  final LocalStorage _storage = LocalStorage();
  int _index = 0;

  static const List<_TourFeature> _features = [
    _TourFeature(
      title: 'Batas Aman Harian',
      subtitle:
          'NataSaku mengubah dana periode menjadi jatah harian yang mudah dipahami.',
      icon: Icons.account_balance_wallet_rounded,
      color: AppTheme.primary,
      metric: 'Rp75.000',
      helper: 'aman untuk hari ini',
    ),
    _TourFeature(
      title: 'Catat Cepat',
      subtitle:
          'Tambah pengeluaran dari aplikasi, widget, atau notifikasi tanpa ribet.',
      icon: Icons.flash_on_rounded,
      color: AppTheme.warning,
      metric: '+10k',
      helper: 'langsung tersimpan',
    ),
    _TourFeature(
      title: 'Notifikasi Stay Bar',
      subtitle:
          'Quick Tools tampil tenang di notification bar, silent, dan siap dipakai kapan saja.',
      icon: Icons.notifications_active_rounded,
      color: AppTheme.info,
      metric: 'Silent',
      helper: 'tidak mengganggu',
    ),
    _TourFeature(
      title: 'Laporan Advanced',
      subtitle:
          'Lihat kategori terbesar, tren harian, insight, lalu export laporan PDF.',
      icon: Icons.insert_chart_rounded,
      color: AppTheme.success,
      metric: 'PDF',
      helper: 'siap dibagikan',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _storage.saveDashboardTutorialSeen(true);
    if (!mounted) return;
    context.go(AppRouter.setup);
  }

  void _next() {
    if (_index == _features.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final feature = _features[_index];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tour Fitur NataSaku',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Lewati'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Kenali alur harian NataSaku dalam beberapa langkah singkat.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _features.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    return _AnimatedFeatureSlide(
                      key: ValueKey(_features[index].title),
                      feature: _features[index],
                      active: index == _index,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  feature.title,
                  key: ValueKey(feature.title),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  feature.subtitle,
                  key: ValueKey(feature.subtitle),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  for (var i = 0; i < _features.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      width: i == _index ? 28 : 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppTheme.primary
                            : AppTheme.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: 156,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 50),
                      ),
                      onPressed: _next,
                      icon: Icon(
                        _index == _features.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _index == _features.length - 1
                            ? 'Mulai Setup'
                            : 'Lanjut',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedFeatureSlide extends StatelessWidget {
  const _AnimatedFeatureSlide({
    super.key,
    required this.feature,
    required this.active,
  });

  final _TourFeature feature;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: active ? 1 : 0.94),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: feature.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: feature.color.withValues(alpha: 0.16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: -0.08, end: 0.08),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (context, angle, child) {
                  return Transform.rotate(angle: angle, child: child);
                },
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: feature.color,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: feature.color.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(feature.icon, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Container(
                  key: ValueKey(feature.metric),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        feature.metric,
                        style: TextStyle(
                          color: feature.color,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.helper,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourFeature {
  const _TourFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.metric,
    required this.helper,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String metric;
  final String helper;
}
