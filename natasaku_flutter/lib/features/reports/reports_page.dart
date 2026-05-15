import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../app/router.dart';
import '../../app/theme/app_theme.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/report_pdf_service.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/budget_period.dart';
import '../../data/models/budget_status.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../budgeting/budgeting_engine.dart';
import '../../shared/widgets/main_shell.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final BudgetRepository _repo = BudgetRepository(LocalStorage());
  final ReportPdfService _reportPdfService = ReportPdfService();
  bool _loading = true;
  List<TransactionModel> _tx = <TransactionModel>[];
  String? _reportInfo;
  BudgetPeriod? _period;
  double _savingBalance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tx = await _repo.loadTransactions();
    final period = await _repo.loadPeriod();
    final savingBalance = await _repo.loadSavingBalance();
    if (!mounted) return;
    setState(() {
      _tx = tx;
      _period = period;
      _savingBalance = savingBalance;
      _loading = false;
    });
  }

  Future<void> _exportPdfReport() async {
    final expenses = _tx.where((t) => t.isExpense).toList();
    final incomes = _tx.where((t) => !t.isExpense).toList();
    final totalExpense = expenses.fold<double>(0, (a, b) => a + b.amount);
    final totalIncome = incomes.fold<double>(0, (a, b) => a + b.amount);
    final averageExpense =
        expenses.isEmpty ? 0.0 : totalExpense / expenses.length;

    final file = await _reportPdfService.exportMonthlyReportPdf(
      transactions: _tx,
      activePeriod: _period,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      averageExpense: averageExpense,
      savingBalance: _savingBalance,
    );

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Laporan berhasil disimpan di folder NataSaku/Reports'),
        action: SnackBarAction(
          label: 'BUKA',
          onPressed: () => OpenFilex.open(file.path),
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    setState(() {
      _reportInfo = 'Laporan: ${file.path.split('/').last}';
    });
  }

  void _onNavigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.transactions);
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.savings);
      case 4:
        Navigator.pushReplacementNamed(context, AppRouter.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenses = _tx.where((t) => t.isExpense).toList();
    final incomes = _tx.where((t) => !t.isExpense).toList();
    final totalExpense = expenses.fold<double>(0, (a, b) => a + b.amount);
    final totalIncome = incomes.fold<double>(0, (a, b) => a + b.amount);
    final avgExpense = expenses.isEmpty ? 0.0 : totalExpense / expenses.length;
    final netBalance =
        (_period?.flexibleFund ?? 0) + totalIncome - totalExpense;
    final biggestExpense = expenses.isEmpty
        ? null
        : expenses.reduce((a, b) => a.amount >= b.amount ? a : b);
    final remainingDays = _period == null
        ? 0
        : BudgetingEngine.calculateRemainingDays(
            today: DateTime.now(),
            periodEnd: _period!.endDate,
          );
    final periodStatus = _period == null
        ? null
        : BudgetingEngine.getPeriodFundStatus(
            remainingFund: netBalance,
            remainingDays: remainingDays,
          );
    final periodUsage = _period == null || _period!.flexibleFund <= 0
        ? 0.0
        : (totalExpense / _period!.flexibleFund).clamp(0, 1).toDouble();

    final categoryTotals = _buildCategoryTotals(expenses);
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dailyTotals = _buildDailyTotals(expenses);
    final sortedDaily = dailyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final projectionText = _period == null
        ? 'Atur periode dulu agar NataSaku bisa memprediksi kondisi sampai akhir periode.'
        : BudgetingEngine.generateRecoveryPlan(
            remainingFund: netBalance,
            remainingDays: remainingDays,
          );
    final managerInsight = _buildManagerInsight(
      sortedCategories: sortedCategories,
      totalExpense: totalExpense,
      periodStatus: periodStatus,
      projectionText: projectionText,
    );
    final insightLines = _buildInsightLines(
      sortedCategories: sortedCategories,
      sortedDaily: sortedDaily,
      totalExpense: totalExpense,
      periodStatus: periodStatus,
      projectionText: projectionText,
    );

    final safeDaily = _period == null
        ? 0.0
        : (_period!.flexibleFund <= 0
            ? 0.0
            : _period!.flexibleFund /
                math.max(
                    1,
                    _period!.endDate.difference(_period!.startDate).inDays +
                        1));

    return MainShell(
      index: 2,
      onNavigate: (index) => _onNavigate(context, index),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    title: const Text('Laporan'),
                    actions: [
                      IconButton(
                        onPressed: _exportPdfReport,
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        tooltip: 'Unduh PDF',
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Text(
                            'Laporan ini membantu kamu memahami uang habis ke mana dan apa langkah paling realistis setelahnya.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          _PeriodHeaderCard(
                            periodLabel: _period == null
                                ? 'Belum diatur'
                                : '${_fmtDate(_period!.startDate)} - ${_fmtDate(_period!.endDate)}',
                            statusLabel: periodStatus == null
                                ? 'Belum aktif'
                                : _periodStatusLabel(periodStatus),
                          ),
                          _ManagerInsightCard(
                            message: managerInsight,
                            statusLabel: periodStatus == null
                                ? 'Belum aktif'
                                : _periodStatusLabel(periodStatus),
                          ),
                          _ExecutiveSummaryCard(
                            items: [
                              _ReportSummaryItem(
                                label: 'Total Pengeluaran',
                                value:
                                    CurrencyService.formatRupiah(totalExpense),
                              ),
                              _ReportSummaryItem(
                                label: 'Total Pemasukan',
                                value:
                                    CurrencyService.formatRupiah(totalIncome),
                              ),
                              _ReportSummaryItem(
                                label: 'Sisa Dana',
                                value: CurrencyService.formatRupiah(netBalance),
                              ),
                              _ReportSummaryItem(
                                label: 'Status Dana Periode',
                                value: periodStatus == null
                                    ? 'Belum aktif'
                                    : _periodStatusLabel(periodStatus),
                              ),
                            ],
                          ),
                          if (_reportInfo != null) ...[
                            const SizedBox(height: 8),
                            Card(
                              child: ListTile(
                                title: const Text('Status Laporan'),
                                subtitle: Text(_reportInfo!),
                              ),
                            ),
                          ],
                          _PeriodProgressCard(progress: periodUsage),
                          _MetricCard(
                            title: 'Ringkasan Pengeluaran',
                            value: biggestExpense == null
                                ? 'Belum ada data pengeluaran.'
                                : 'Pengeluaran terbesar saat ini ${CurrencyService.formatRupiah(biggestExpense.amount)}${biggestExpense.category == null ? '' : ' di kategori ${biggestExpense.category}.'}\nRata-rata pengeluaran harian ${CurrencyService.formatRupiah(avgExpense)}.',
                          ),
                          _ProjectionCard(value: projectionText),
                          _InsightsCard(lines: insightLines),
                          _DonutCategoryCard(
                            sortedCategories: sortedCategories,
                            totalExpense: totalExpense,
                          ),
                          _LineDailyTrendCard(sortedDaily: sortedDaily),
                          _BarCategoryCard(
                            sortedCategories: sortedCategories,
                            totalExpense: totalExpense,
                          ),
                          _SafeVsActualCard(
                            sortedDaily: sortedDaily,
                            safeDaily: safeDaily,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRouter.moneyCalendar),
                                icon: const Icon(Icons.calendar_month_outlined),
                                label: const Text('Kalender Uang'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _exportPdfReport,
                                icon: const Icon(Icons.picture_as_pdf_outlined),
                                label: const Text('Unduh PDF'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Map<String, double> _buildCategoryTotals(List<TransactionModel> expenses) {
    final categoryTotals = <String, double>{};
    for (final item in expenses) {
      final key = (item.category?.trim().isNotEmpty ?? false)
          ? item.category!.trim()
          : 'Tanpa Kategori';
      categoryTotals[key] = (categoryTotals[key] ?? 0) + item.amount;
    }
    return categoryTotals;
  }

  Map<String, double> _buildDailyTotals(List<TransactionModel> expenses) {
    final dailyTotals = <String, double>{};
    for (final item in expenses) {
      final key =
          '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';
      dailyTotals[key] = (dailyTotals[key] ?? 0) + item.amount;
    }
    return dailyTotals;
  }

  List<String> _buildInsightLines({
    required List<MapEntry<String, double>> sortedCategories,
    required List<MapEntry<String, double>> sortedDaily,
    required double totalExpense,
    required PeriodFundStatus? periodStatus,
    required String projectionText,
  }) {
    final lines = <String>[];
    if (totalExpense <= 0) {
      lines.add(
          'Belum ada cukup data. Catat transaksi selama 3-5 hari agar insight lebih akurat.');
      return lines;
    }

    if (sortedCategories.isNotEmpty) {
      final top = sortedCategories.first;
      final pct = ((top.value / totalExpense) * 100).toStringAsFixed(0);
      lines.add(
          'Pengeluaran terbesar kamu ada di ${top.key} (${CurrencyService.formatRupiah(top.value)} atau $pct% dari total).');
    }
    if (sortedDaily.isNotEmpty) {
      final peak = sortedDaily.reduce((a, b) => a.value >= b.value ? a : b);
      lines.add(
          'Pengeluaran tertinggi terjadi di ${peak.key} sebesar ${CurrencyService.formatRupiah(peak.value)}.');
    }
    lines.add(projectionText);
    if (periodStatus == PeriodFundStatus.waspada ||
        periodStatus == PeriodFundStatus.kritis ||
        periodStatus == PeriodFundStatus.danaHabis) {
      lines.add(
          'Saran cepat: fokus ke kebutuhan wajib dulu dan tahan belanja opsional 2-3 hari ke depan.');
    } else {
      lines.add(
          'Posisi masih aman. Pertahankan pola ini agar akhir periode tetap nyaman.');
    }
    return lines;
  }

  String _buildManagerInsight({
    required List<MapEntry<String, double>> sortedCategories,
    required double totalExpense,
    required PeriodFundStatus? periodStatus,
    required String projectionText,
  }) {
    if (_period == null) {
      return 'Dana kamu belum punya periode aktif. Atur periode dulu agar prediksi harian dan akhir periode lebih akurat.';
    }
    if (totalExpense <= 0) {
      return 'Dana kamu masih aman sampai akhir periode. Mulai catat transaksi agar prediksi berikutnya lebih akurat.';
    }
    if (sortedCategories.isNotEmpty) {
      final top = sortedCategories.first;
      if (periodStatus == PeriodFundStatus.kritis ||
          periodStatus == PeriodFundStatus.danaHabis) {
        return 'Pengeluaran terbesar kamu ada di kategori ${top.key}. Kamu perlu menahan sekitar pengeluaran kecil harian agar posisi lebih stabil. $projectionText';
      }
      return 'Pengeluaran terbesar kamu ada di kategori ${top.key}. Posisi dana masih bisa dijaga kalau pola ini tetap terkendali.';
    }
    return projectionText;
  }

  String _periodStatusLabel(PeriodFundStatus status) {
    switch (status) {
      case PeriodFundStatus.aman:
        return 'Aman';
      case PeriodFundStatus.waspada:
        return 'Waspada';
      case PeriodFundStatus.kritis:
        return 'Kritis';
      case PeriodFundStatus.danaHabis:
        return 'Dana Habis';
      case PeriodFundStatus.periodeSelesai:
        return 'Periode Selesai';
    }
  }

  String _fmtDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodHeaderCard extends StatelessWidget {
  const _PeriodHeaderCard({
    required this.periodLabel,
    required this.statusLabel,
  });

  final String periodLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.date_range_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periode Laporan',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  periodLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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

class _ManagerInsightCard extends StatelessWidget {
  const _ManagerInsightCard({required this.message, required this.statusLabel});

  final String message;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                bottom: BorderSide(color: AppTheme.border.withValues(alpha: 0.4)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Catatan Manager Keuangan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusLabel == 'Aman'
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : (statusLabel == 'Waspada'
                            ? AppTheme.warning.withValues(alpha: 0.1)
                            : AppTheme.error.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusLabel == 'Aman'
                          ? AppTheme.success
                          : (statusLabel == 'Waspada'
                              ? AppTheme.warning
                              : AppTheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo,',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Salam,\nNataSaku System',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
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

class _ReportSummaryItem {
  const _ReportSummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _ExecutiveSummaryCard extends StatelessWidget {
  const _ExecutiveSummaryCard({required this.items});

  final List<_ReportSummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Utama',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isIncome = item.label.toLowerCase().contains('pemasukan');
            final isExpense = item.label.toLowerCase().contains('pengeluaran');
            final isStatus = item.label.toLowerCase().contains('status');
            
            Color iconColor = AppTheme.primary;
            IconData icon = Icons.account_balance_wallet_rounded;
            
            if (isIncome) {
              iconColor = AppTheme.success;
              icon = Icons.south_west_rounded;
            } else if (isExpense) {
              iconColor = AppTheme.error;
              icon = Icons.north_east_rounded;
            } else if (isStatus) {
              iconColor = AppTheme.warning;
              icon = Icons.info_outline_rounded;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: iconColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rekomendasi NataSaku',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              height: 1.5,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodProgressCard extends StatelessWidget {
  const _PeriodProgressCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Dana Periode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppTheme.error : (progress > 0.6 ? AppTheme.warning : AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% terpakai',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (progress > 0.8)
                const Text(
                  'Hati-hati',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekomendasi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }
}

class _DonutCategoryCard extends StatelessWidget {
  const _DonutCategoryCard({
    required this.sortedCategories,
    required this.totalExpense,
  });

  final List<MapEntry<String, double>> sortedCategories;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      AppTheme.primary,
      const Color(0xFF2EAD6B),
      const Color(0xFFF59E3D),
      const Color(0xFF4A90E2),
      const Color(0xFFE85D5D),
    ];
    final top = sortedCategories.take(5).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Pengeluaran',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lihat kategori mana yang paling banyak menyerap uangmu.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (top.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text(
                'Belum ada data kategori.\nCatat pengeluaranmu terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 50,
                  sectionsSpace: 4,
                  sections: [
                    for (var i = 0; i < top.length; i++)
                      PieChartSectionData(
                        value: top[i].value,
                        color: colors[i % colors.length],
                        title:
                            '${((top[i].value / totalExpense) * 100).toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 24),
            for (var i = 0; i < top.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        top[i].key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyService.formatRupiah(top[i].value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _LineDailyTrendCard extends StatelessWidget {
  const _LineDailyTrendCard({required this.sortedDaily});

  final List<MapEntry<String, double>> sortedDaily;

  @override
  Widget build(BuildContext context) {
    final points = sortedDaily.take(10).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tren Pengeluaran Harian',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Grafik ini membantu melihat hari mana pengeluaranmu naik atau turun.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (points.isEmpty)
              Text(
                'Belum ada tren harian yang bisa ditampilkan.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: AppTheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primary.withValues(alpha: 0.12),
                        ),
                        spots: [
                          for (var i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), points[i].value),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarCategoryCard extends StatelessWidget {
  const _BarCategoryCard({
    required this.sortedCategories,
    required this.totalExpense,
  });

  final List<MapEntry<String, double>> sortedCategories;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final top = sortedCategories.take(5).toList();
    final maxValue = top.isEmpty
        ? 1.0
        : top.fold<double>(0.0, (max, e) => e.value > max ? e.value : max);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan Kategori',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Bandingkan kategori pengeluaran dengan lebih cepat.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (top.isEmpty)
              Text(
                'Belum ada data kategori.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: [
                      for (var i = 0; i < top.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: top[i].value,
                              width: 20,
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                    ],
                    maxY: maxValue * 1.15,
                  ),
                ),
              ),
            if (top.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final item in top)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.key)),
                      Text(
                        '${((item.value / totalExpense) * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SafeVsActualCard extends StatelessWidget {
  const _SafeVsActualCard({
    required this.sortedDaily,
    required this.safeDaily,
  });

  final List<MapEntry<String, double>> sortedDaily;
  final double safeDaily;

  @override
  Widget build(BuildContext context) {
    final points = sortedDaily.take(10).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batas Aman vs Pengeluaran Aktual',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Bandingkan jatah aman dengan pengeluaran nyata agar kamu tahu seberapa stabil polanya.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (points.isEmpty || safeDaily <= 0)
              Text(
                'Data belum cukup untuk membandingkan jatah aman dan pengeluaran aktual.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: false,
                        color: AppTheme.warning,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        spots: [
                          for (var i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), points[i].value),
                        ],
                      ),
                      LineChartBarData(
                        isCurved: false,
                        color: AppTheme.success,
                        barWidth: 2.5,
                        dashArray: [6, 3],
                        dotData: const FlDotData(show: false),
                        spots: [
                          for (var i = 0; i < points.length; i++)
                            FlSpot(i.toDouble(), safeDaily),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _LegendDot(color: AppTheme.warning, label: 'Aktual'),
                SizedBox(width: 12),
                _LegendDot(color: AppTheme.success, label: 'Jatah Aman'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
