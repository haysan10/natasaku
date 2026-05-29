import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import '../../data/datasources/local/local_storage.dart';
import 'feature_tour_overlay.dart';

/// GlobalKeys untuk spotlight feature tour.
/// Dipasang pada widget target di berbagai halaman.
class TourKeys {
  // Dashboard
  static final heroCard = GlobalKey(debugLabel: 'tour_hero_card');
  static final fabButton = GlobalKey(debugLabel: 'tour_fab');
  // Transactions
  static final transactionSearch = GlobalKey(debugLabel: 'tour_transaction_search');
  // Budget
  static final budgetCard = GlobalKey(debugLabel: 'tour_budget_card');
  // Savings
  static final savingsGoal = GlobalKey(debugLabel: 'tour_savings_goal');
  // Reports
  static final reportsChart = GlobalKey(debugLabel: 'tour_reports_chart');
  // Settings (Utang)
  static final debtsMenu = GlobalKey(debugLabel: 'tour_debts_menu');
}

/// GlobalFeatureTourManager — widget pembungkus yang mengatur feature tour global.
///
/// Dipasang di `MaterialApp.router` (lib/app/app.dart) untuk memastikan overlay 
/// ini selalu berada di atas semua halaman.
class GlobalFeatureTourManager extends StatefulWidget {
  const GlobalFeatureTourManager({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalFeatureTourManager> createState() => _GlobalFeatureTourManagerState();
}

class _GlobalFeatureTourManagerState extends State<GlobalFeatureTourManager> {
  final _storage = LocalStorage();
  bool _showTour = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    // Listen to router changes to detect when we reach dashboard
    AppRouter.router.routerDelegate.addListener(_routerListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTour();
    });
  }

  @override
  void dispose() {
    AppRouter.router.routerDelegate.removeListener(_routerListener);
    super.dispose();
  }

  void _routerListener() {
    if (!_showTour && !_completed) {
      _checkTour();
    }
  }

  Future<void> _checkTour() async {
    if (!mounted || _completed) return;
    
    final completed = await _storage.getFeatureTourCompleted();
    if (completed) {
      if (mounted) setState(() => _completed = true);
      return;
    }

    final period = await _storage.getBudgetPeriod();
    if (period == null) return; // Belum set budget

    // Hanya mulai tour jika kita berada di halaman dashboard
    // Ini mencegah tour dimulai prematur saat splash/setup
    final currentPath = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    if (currentPath == AppRouter.dashboard) {
      if (mounted) {
        setState(() {
          _showTour = true;
        });
      }
    }
  }

  Future<void> _onTourComplete() async {
    await _storage.saveFeatureTourCompleted(true);
    if (mounted) {
      setState(() {
        _showTour = false;
        _completed = true;
      });
      // Optionally return to dashboard after tour
      AppRouter.router.go(AppRouter.dashboard);
    }
  }

  List<TourStep> get _tourSteps => [
        TourStep(
          targetRoute: AppRouter.dashboard,
          targetKey: TourKeys.heroCard,
          tooltipTitle: 'Jatah Harianmu 💚',
          tooltipBody:
              'Angka ini dihitung otomatis dari dana periodemu. Selama sisa ini positif, keuanganmu aman hari ini!',
          actionLabel: 'Lanjut →',
          overlayPadding: 10,
        ),
        TourStep(
          targetRoute: AppRouter.dashboard,
          targetKey: TourKeys.fabButton,
          tooltipTitle: 'Catat Pengeluaran ✍️',
          tooltipBody:
              'Tap tombol ini setiap kali kamu belanja. Cukup isi nominal dan kategori — selesai dalam 3 detik!',
          actionLabel: 'Lanjut →',
          overlayPadding: 6,
          isCircle: true,
        ),
        TourStep(
          targetRoute: AppRouter.transactions,
          targetKey: TourKeys.transactionSearch,
          tooltipTitle: 'Riwayat Transaksi 🔍',
          tooltipBody:
              'Semua catatan pengeluaran dan pemasukanmu terkumpul di sini. Kamu bisa mencari atau memfilternya dengan mudah.',
          actionLabel: 'Lanjut →',
          overlayPadding: 8,
        ),
        TourStep(
          targetRoute: AppRouter.budget,
          targetKey: TourKeys.budgetCard,
          tooltipTitle: 'Pantau Budgetmu 📝',
          tooltipBody:
              'Lihat detail sisa budget dan alokasi danamu per periode di halaman ini.',
          actionLabel: 'Lanjut →',
          overlayPadding: 8,
        ),
        TourStep(
          targetRoute: AppRouter.savings,
          targetKey: TourKeys.savingsGoal,
          tooltipTitle: 'Celengan Digital 🐷',
          tooltipBody:
              'Sisa jatah harian bisa langsung ditabung. Target tabunganmu dipantau di sini.',
          actionLabel: 'Lanjut →',
          overlayPadding: 8,
        ),
        TourStep(
          targetRoute: AppRouter.reports,
          targetKey: TourKeys.reportsChart,
          tooltipTitle: 'Laporan & Analisis 📊',
          tooltipBody:
              'Lihat tren pengeluaran, perbandingan Needs vs Wants, dan export laporan ke PDF.',
          actionLabel: 'Lanjut →',
          overlayPadding: 8,
        ),
        TourStep(
          targetRoute: AppRouter.settings,
          targetKey: TourKeys.debtsMenu,
          tooltipTitle: 'Mode Utang 🤝',
          tooltipBody:
              'Catat siapa yang utang ke kamu atau sebaliknya. Fitur ini ada di dalam menu Pengaturan!',
          actionLabel: 'Selesai 🎉',
          overlayPadding: 4,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return FeatureTourOverlay(
      steps: _tourSteps,
      showTour: _showTour,
      onComplete: _onTourComplete,
      onNavigate: (route) async {
        AppRouter.router.go(route);
      },
      child: widget.child,
    );
  }
}
