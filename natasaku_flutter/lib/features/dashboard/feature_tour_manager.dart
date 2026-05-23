import 'package:flutter/material.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../shared/widgets/feature_tour_overlay.dart';

/// GlobalKeys untuk spotlight feature tour.
/// Dipasang pada widget target di DashboardPage dan MainShell.
class TourKeys {
  static final heroCard = GlobalKey(debugLabel: 'tour_hero_card');
  static final fabButton = GlobalKey(debugLabel: 'tour_fab');
  static final statusChip = GlobalKey(debugLabel: 'tour_status_chip');
  static final navReports = GlobalKey(debugLabel: 'tour_nav_reports');
  static final navSavings = GlobalKey(debugLabel: 'tour_nav_savings');
}

/// FeatureTourManager — widget pembungkus yang mengatur feature tour 5 langkah.
///
/// Dipasang di DashboardPage untuk memutuskan kapan tour ditampilkan:
/// - Cek `LocalStorage.getFeatureTourCompleted()` on mount
/// - Jika false (dan budget sudah ada) → tampilkan FeatureTourOverlay
/// - Saat selesai/skip → simpan `feature_tour_completed = true`
class FeatureTourManager extends StatefulWidget {
  const FeatureTourManager({
    super.key,
    required this.child,
    required this.hasBudget,
  });

  final Widget child;
  /// true jika user sudah setup budget periode (data tidak null)
  final bool hasBudget;

  @override
  State<FeatureTourManager> createState() => _FeatureTourManagerState();
}

class _FeatureTourManagerState extends State<FeatureTourManager> {
  final _storage = LocalStorage();
  bool _showTour = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkTour();
  }

  @override
  void didUpdateWidget(FeatureTourManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasBudget && widget.hasBudget && !_checked) {
      _checkTour();
    }
  }

  Future<void> _checkTour() async {
    if (!widget.hasBudget) return;
    final completed = await _storage.getFeatureTourCompleted();
    if (!completed && mounted) {
      setState(() {
        _showTour = true;
        _checked = true;
      });
    } else {
      setState(() => _checked = true);
    }
  }

  Future<void> _onTourComplete() async {
    await _storage.saveFeatureTourCompleted(true);
    if (mounted) setState(() => _showTour = false);
  }

  List<TourStep> get _tourSteps => [
        TourStep(
          targetKey: TourKeys.heroCard,
          tooltipTitle: 'Ini Jatah Harianmu 💚',
          tooltipBody:
              'Angka ini dihitung otomatis dari dana periodemu. Selama sisa ini positif, keuanganmu aman hari ini!',
          actionLabel: 'Mengerti →',
          overlayPadding: 10,
        ),
        TourStep(
          targetKey: TourKeys.fabButton,
          tooltipTitle: 'Catat Setiap Pengeluaran ✍️',
          tooltipBody:
              'Tap tombol ini setiap kali kamu belanja. Cukup isi nominal dan kategori — selesai dalam 3 detik!',
          actionLabel: 'Oke →',
          overlayPadding: 6,
        ),
        TourStep(
          targetKey: TourKeys.statusChip,
          tooltipTitle: 'Status Kondisi Keuangan 🎯',
          tooltipBody:
              'Warna dan label ini berubah real-time. Hijau = aman, kuning = waspada, merah muda = melewati batas.',
          actionLabel: 'Paham →',
          overlayPadding: 8,
        ),
        TourStep(
          targetKey: TourKeys.navReports,
          tooltipTitle: 'Laporan & Analisis 📊',
          tooltipBody:
              'Di sini kamu bisa lihat tren pengeluaran 7 hari, kategori terbesar, dan export laporan PDF.',
          actionLabel: 'Lihat →',
          overlayPadding: 6,
        ),
        TourStep(
          targetKey: TourKeys.navSavings,
          tooltipTitle: 'Celengan Digitalmu 🐷',
          tooltipBody:
              'Sisa jatah harian bisa langsung ditabung ke Celengan. Target tabunganmu dipantau di sini.',
          actionLabel: 'Selesai 🎉',
          overlayPadding: 6,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return FeatureTourOverlay(
      steps: _tourSteps,
      showTour: _showTour,
      onComplete: _onTourComplete,
      child: widget.child,
    );
  }
}
