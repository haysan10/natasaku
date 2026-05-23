import 'package:flutter/material.dart';
import '../../core/animations/nata_animations.dart';

enum NataBudgetStatus { safe, warning, overBudget }

/// Status chip dengan crossfade / smooth animation saat status berubah.
///
/// Warna status:
/// - SAFE:        primaryContainer teal/mint — "Aman ✅"
/// - WARNING:     warningSoft amber          — "Waspada ⚠️"
/// - OVER_BUDGET: errorSoft rose (BUKAN merah penuh) — "Melewati Batas 🚨"
class NataStatusChip extends StatelessWidget {
  const NataStatusChip({
    super.key,
    required this.status,
  });

  final NataBudgetStatus status;

  _ChipConfig get _config {
    switch (status) {
      case NataBudgetStatus.safe:
        return const _ChipConfig(
          label: 'Aman ✅',
          containerColor: Color(0xFFE6FAF5),
          textColor: Color(0xFF0F766E),
          borderColor: Color(0xFFCCFBF1),
        );
      case NataBudgetStatus.warning:
        return const _ChipConfig(
          label: 'Waspada ⚠️',
          containerColor: Color(0xFFFEF3C7),
          textColor: Color(0xFF92400E),
          borderColor: Color(0xFFFDE68A),
        );
      case NataBudgetStatus.overBudget:
        return const _ChipConfig(
          label: 'Melewati Batas 🚨',
          containerColor: Color(0xFFFEE2E2),
          textColor: Color(0xFF991B1B),
          borderColor: Color(0xFFFECACA),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return AnimatedContainer(
      duration: NataDuration.normal,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.borderColor),
      ),
      child: AnimatedDefaultTextStyle(
        duration: NataDuration.normal,
        curve: Curves.easeInOut,
        style: TextStyle(
          color: config.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        child: Text(config.label),
      ),
    );
  }
}

/// Dark-mode aware version of NataStatusChip (for use on colored backgrounds)
class NataStatusChipOnDark extends StatelessWidget {
  const NataStatusChipOnDark({super.key, required this.status});

  final NataBudgetStatus status;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case NataBudgetStatus.safe:
        label = 'Aman ✅';
        color = const Color(0xFF6EE7B7);
        break;
      case NataBudgetStatus.warning:
        label = 'Waspada ⚠️';
        color = const Color(0xFFFCD34D);
        break;
      case NataBudgetStatus.overBudget:
        label = 'Melewati Batas 🚨';
        color = const Color(0xFFFCA5A5);
        break;
    }

    return AnimatedContainer(
      duration: NataDuration.normal,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: AnimatedDefaultTextStyle(
        duration: NataDuration.normal,
        curve: Curves.easeInOut,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Helper untuk menghitung NataBudgetStatus dari spent/budget ratio
NataBudgetStatus budgetStatusFromRatio(double ratio) {
  if (ratio > 1.0) return NataBudgetStatus.overBudget;
  if (ratio > 0.7) return NataBudgetStatus.warning;
  return NataBudgetStatus.safe;
}

class _ChipConfig {
  const _ChipConfig({
    required this.label,
    required this.containerColor,
    required this.textColor,
    required this.borderColor,
  });

  final String label;
  final Color containerColor;
  final Color textColor;
  final Color borderColor;
}
