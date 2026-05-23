import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/report_export_service.dart';
import '../../core/services/report_pdf_service.dart';
import '../notifications/notifications_service.dart';
import '../../data/models/budget_status.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_period.dart';
import '../../data/models/budget_mode.dart';
import '../budgeting/budgeting_engine.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/widgets/empty_state.dart';

enum ReportInterval { activePeriod, today, thisWeek, thisMonth, thisYear, custom }

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportPdfService _reportPdfService = ReportPdfService();
  final ReportExportService _reportExportService = ReportExportService();
  final NotificationsService _notificationsService = NotificationsService();
  
  bool _isExporting = false;
  ReportInterval _selectedInterval = ReportInterval.activePeriod;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  DateTime _pivotDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavigate(int index) {
    switch (index) {
      case 0: context.go(AppRouter.dashboard); break;
      case 1: context.go(AppRouter.transactions); break;
      case 2: context.go(AppRouter.budget); break;
      case 3: context.go(AppRouter.savings); break;
      case 4: break; // current
    }
  }

  DateTimeRange _calculateDateRange(ReportInterval interval, BudgetPeriod? activePeriod) {
    switch (interval) {
      case ReportInterval.today:
        final start = DateTime(_pivotDate.year, _pivotDate.month, _pivotDate.day);
        final end = DateTime(_pivotDate.year, _pivotDate.month, _pivotDate.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case ReportInterval.thisWeek:
        final daysToMonday = _pivotDate.weekday - DateTime.monday;
        final start = DateTime(_pivotDate.year, _pivotDate.month, _pivotDate.day).subtract(Duration(days: daysToMonday));
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateTimeRange(start: start, end: end);
      case ReportInterval.thisMonth:
        final start = DateTime(_pivotDate.year, _pivotDate.month, 1);
        final end = DateTime(_pivotDate.year, _pivotDate.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case ReportInterval.thisYear:
        final start = DateTime(_pivotDate.year, 1, 1);
        final end = DateTime(_pivotDate.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case ReportInterval.custom:
        final start = _customStartDate ?? activePeriod?.startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = _customEndDate ?? activePeriod?.endDate ?? DateTime.now();
        return DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: DateTime(end.year, end.month, end.day, 23, 59, 59),
        );
      case ReportInterval.activePeriod:
        final start = activePeriod?.startDate ?? DateTime.now().subtract(const Duration(days: 30));
        final end = activePeriod?.endDate ?? DateTime.now();
        return DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: DateTime(end.year, end.month, end.day, 23, 59, 59),
        );
    }
  }

  Future<void> _pickCustomRange(BudgetPeriod? activePeriod) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: _customStartDate ?? activePeriod?.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _customEndDate ?? activePeriod?.endDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedInterval = ReportInterval.custom;
        _pivotDate = DateTime.now();
      });
    }
  }

  String _formatIntervalLabel(DateTimeRange range) {
    switch (_selectedInterval) {
      case ReportInterval.today:
        return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(range.start);
      case ReportInterval.thisWeek:
        final startStr = DateFormat('dd MMM', 'id_ID').format(range.start);
        final endStr = DateFormat('dd MMM yyyy', 'id_ID').format(range.end);
        return 'Minggu: $startStr - $endStr';
      case ReportInterval.thisMonth:
        return DateFormat('MMMM yyyy', 'id_ID').format(range.start);
      case ReportInterval.thisYear:
        return DateFormat('yyyy', 'id_ID').format(range.start);
      case ReportInterval.custom:
        final startStr = DateFormat('dd MMM yyyy', 'id_ID').format(range.start);
        final endStr = DateFormat('dd MMM yyyy', 'id_ID').format(range.end);
        return '$startStr - $endStr';
      case ReportInterval.activePeriod:
        final startStr = DateFormat('dd MMM yyyy', 'id_ID').format(range.start);
        final endStr = DateFormat('dd MMM yyyy', 'id_ID').format(range.end);
        return 'Periode: $startStr - $endStr';
    }
  }

  void _navigatePeriod({required bool forward}) {
    HapticFeedback.lightImpact();
    setState(() {
      final direction = forward ? 1 : -1;
      switch (_selectedInterval) {
        case ReportInterval.today:
          _pivotDate = _pivotDate.add(Duration(days: 1 * direction));
          break;
        case ReportInterval.thisWeek:
          _pivotDate = _pivotDate.add(Duration(days: 7 * direction));
          break;
        case ReportInterval.thisMonth:
          _pivotDate = DateTime(_pivotDate.year, _pivotDate.month + (1 * direction), 1);
          break;
        case ReportInterval.thisYear:
          _pivotDate = DateTime(_pivotDate.year + (1 * direction), 1, 1);
          break;
        case ReportInterval.custom:
          if (_customStartDate != null && _customEndDate != null) {
            final duration = _customEndDate!.difference(_customStartDate!);
            final days = duration.inDays == 0 ? 1 : duration.inDays;
            _customStartDate = _customStartDate!.add(Duration(days: days * direction));
            _customEndDate = _customEndDate!.add(Duration(days: days * direction));
          }
          break;
        case ReportInterval.activePeriod:
          break;
      }
    });
  }

  Future<void> _exportPdfReport(DashboardState state, {bool share = false}) async {
    if (state.period == null) return;
    setState(() => _isExporting = true);

    try {
      final expenses = state.transactions.where((t) => t.isExpense).toList();
      final totalExpense = state.totalExpense;
      final totalIncome = state.totalIncome;
      final averageExpense = expenses.isEmpty ? 0.0 : totalExpense / expenses.length;
      final savingBalance = state.savingGoal?.currentAmount ?? 0.0;

      final file = await _reportPdfService.exportMonthlyReportPdf(
        transactions: state.transactions,
        activePeriod: state.period,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        averageExpense: averageExpense,
        savingBalance: savingBalance,
        healthScore: state.healthScore,
      );

      if (!mounted) return;

      if (share) {
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Laporan Keuangan NataSaku',
          text: 'Laporan keuangan saya — dibuat dengan NataSaku.',
        );
      } else {
        _showExportSuccess(file.path, 'Laporan PDF Siap!');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportExcelReport(DashboardState state, {bool share = false}) async {
    setState(() => _isExporting = true);
    try {
      final file = await _reportExportService.exportTransactionsExcel(
        transactions: state.transactions,
        activePeriod: state.period,
        totalIncome: state.totalIncome,
        totalExpense: state.totalExpense,
        healthScore: state.healthScore,
      );

      if (!mounted) return;

      if (share) {
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: 'Laporan Excel NataSaku',
          text: 'Data transaksi keuangan saya — diekspor dari NataSaku.',
        );
      } else {
        _showExportSuccess(file.path, 'Laporan Excel Siap!');
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showExportSuccess(String path, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Disimpan di: NataSaku/Reports', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
          ],
        ),
        action: SnackBarAction(
          label: 'BUKA',
          textColor: AppColors.primarySoft,
          onPressed: () => OpenFilex.open(path),
        ),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    _notificationsService.showExportCompleteNotification(fileName: path.split('/').last);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter calculations
    final range = _calculateDateRange(_selectedInterval, state.period);
    final filteredTxs = state.transactions.where((t) => 
      t.date.isAfter(range.start.subtract(const Duration(seconds: 1))) && 
      t.date.isBefore(range.end.add(const Duration(seconds: 1)))
    ).toList();

    final customPeriod = BudgetPeriod(
      id: state.period?.id ?? 'filtered_period',
      startDate: range.start,
      endDate: range.end,
      flexibleFund: state.period?.flexibleFund ?? 0,
      fixedExpenses: state.period?.fixedExpenses ?? 0,
      monthlySavingAllocation: state.period?.monthlySavingAllocation ?? 0,
      mode: state.period?.mode ?? BudgetMode.normal,
    );

    final filteredState = state.copyWith(
      transactions: filteredTxs,
      period: customPeriod,
    );

    return MainShell(
      index: 4,
      onNavigate: _onNavigate,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Executive Report',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              'Laporan Keuangan',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ).animate().fade().slideX(begin: -0.1),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: const PhosphorIcon(PhosphorIconsRegular.chartLineUp, color: AppColors.primary),
                        ).animate().scale(delay: 200.ms),
                      ],
                    ),
                  ),

                  // Horizontal ChoiceChips Date Interval Selector
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('📅 Periode'),
                            selected: _selectedInterval == ReportInterval.activePeriod,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedInterval = ReportInterval.activePeriod;
                                  _pivotDate = DateTime.now();
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('☀️ Hari Ini'),
                            selected: _selectedInterval == ReportInterval.today,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedInterval = ReportInterval.today;
                                  _pivotDate = DateTime.now();
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('📅 Minggu Ini'),
                            selected: _selectedInterval == ReportInterval.thisWeek,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedInterval = ReportInterval.thisWeek;
                                  _pivotDate = DateTime.now();
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('🌙 Bulan Ini'),
                            selected: _selectedInterval == ReportInterval.thisMonth,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedInterval = ReportInterval.thisMonth;
                                  _pivotDate = DateTime.now();
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('✨ Tahun Ini'),
                            selected: _selectedInterval == ReportInterval.thisYear,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedInterval = ReportInterval.thisYear;
                                  _pivotDate = DateTime.now();
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔧 Kustom'),
                                if (_selectedInterval == ReportInterval.custom) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.edit_rounded, size: 12),
                                ],
                              ],
                            ),
                            selected: _selectedInterval == ReportInterval.custom,
                            onSelected: (selected) async {
                              await _pickCustomRange(state.period);
                            },
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 50.ms),

                  // Display Selected Date Range with Interactive Pager Navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left arrow button to navigate back in history
                          if (_selectedInterval != ReportInterval.activePeriod) ...[
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 24),
                              onPressed: () => _navigatePeriod(forward: false),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ] else
                            const SizedBox(width: 24),
                            
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _formatIntervalLabel(range),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Right arrow button to navigate forward in history
                          if (_selectedInterval != ReportInterval.activePeriod) ...[
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 24),
                              onPressed: () => _navigatePeriod(forward: true),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ] else
                            const SizedBox(width: 24),
                        ],
                      ),
                    ),
                  ).animate(key: ValueKey('${_selectedInterval}_${_pivotDate.millisecondsSinceEpoch}')).fade(duration: 200.ms).slideX(begin: 0.02, end: 0),
                  const SizedBox(height: 12),

                  // Custom Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.zero,
                        indicator: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04), 
                              blurRadius: 6, 
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                        tabs: const [
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Ringkasan Eksekutif'),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Buku Kas & Ekspor'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 16),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _ExecutiveSummaryTab(
                          state: filteredState,
                          healthScore: filteredState.healthScore,
                          isExporting: _isExporting,
                          onExportPdf: () => _exportPdfReport(filteredState),
                          onSharePdf: () => _exportPdfReport(filteredState, share: true),
                        ),
                        _LedgerExportTab(
                          state: filteredState,
                          isExporting: _isExporting,
                          onExportPdf: () => _exportPdfReport(filteredState),
                          onExportExcel: () => _exportExcelReport(filteredState),
                          onSharePdf: () => _exportPdfReport(filteredState, share: true),
                          onShareExcel: () => _exportExcelReport(filteredState, share: true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ExecutiveSummaryTab extends StatelessWidget {
  final DashboardState state;
  final int healthScore;
  final bool isExporting;
  final VoidCallback onExportPdf;
  final VoidCallback onSharePdf;

  const _ExecutiveSummaryTab({
    required this.state,
    required this.healthScore,
    required this.isExporting,
    required this.onExportPdf,
    required this.onSharePdf,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenses = state.transactions.where((t) => t.isExpense).toList();
    
    // Precompute top 3 largest transactions for clean rendering
    final sortedExpenses = List<TransactionModel>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final top3Largest = sortedExpenses.take(3).toList();
    
    // Category mapping
    final categoryTotals = <String, double>{};
    for (final t in expenses) {
      final key = t.category?.trim().isEmpty ?? true ? 'Lainnya' : t.category!.trim();
      categoryTotals[key] = (categoryTotals[key] ?? 0) + t.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Manager Advice
    final remainingDays = state.remainingDays;
    final periodStatus = state.period == null ? null : BudgetingEngine.getPeriodFundStatus(
      remainingFund: state.remainingFund,
      remainingDays: remainingDays,
    );

    String managerNote = '';
    if (state.period == null) {
      managerNote = 'Klien belum mengatur periode keuangan. Data belum dapat diproyeksikan.';
    } else {
      final projection = BudgetingEngine.generateRecoveryPlan(
        remainingFund: state.remainingFund,
        remainingDays: remainingDays,
      );
      final statusNote = switch (periodStatus) {
        PeriodFundStatus.aman          => 'Status dana: AMAN — Anda masih dalam jalur anggaran yang sehat.',
        PeriodFundStatus.waspada       => 'Status dana: WASPADA — disarankan mengurangi pengeluaran non-esensial.',
        PeriodFundStatus.kritis        => 'Status dana: KRITIS — perlu kontrol ketat terhadap setiap transaksi.',
        PeriodFundStatus.danaHabis     => 'Status dana: HABIS — dana periode telah terpakai sepenuhnya.',
        PeriodFundStatus.periodeSelesai => 'Status dana: PERIODE SELESAI — periode anggaran sudah berakhir.',
        null                           => '',
      };
      if (sortedCategories.isNotEmpty) {
        final topCat = sortedCategories.first;
        managerNote = '$statusNote Pengeluaran terbesar Anda berada pada kategori "${topCat.key}" (${CurrencyService.formatRupiah(topCat.value)}). $projection';
      } else {
        managerNote = '$statusNote $projection'.trim();
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        // Health Score Card (Circular Gauge Design)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceVariantDark : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: healthScore / 100,
                      strokeWidth: 10,
                      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      color: healthScore >= 80 
                          ? const Color(0xFF10B981) // Emerald Green
                          : healthScore >= 50 
                              ? const Color(0xFFF59E0B) // Amber Yellow
                              : const Color(0xFFEF4444), // Alizarin Red
                      strokeCap: StrokeCap.round,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$healthScore',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          '/100',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (healthScore >= 80 
                            ? const Color(0xFF10B981) 
                            : healthScore >= 50 
                                ? const Color(0xFFF59E0B) 
                                : const Color(0xFFEF4444)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        healthScore >= 80 
                            ? 'PRIMA' 
                            : healthScore >= 50 
                                ? 'WASPADAI' 
                                : 'KRITIS',
                        style: TextStyle(
                          color: healthScore >= 80 
                              ? const Color(0xFF10B981) 
                              : healthScore >= 50 
                                  ? const Color(0xFFF59E0B) 
                                  : const Color(0xFFEF4444),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Skor Kesehatan Finansial',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rasio tabungan & kepatuhan budget harianmu saat ini.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: 16),

        // AI Advisory Recommendation Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (healthScore >= 80 
                ? const Color(0xFF10B981) 
                : healthScore >= 50 
                    ? const Color(0xFFF59E0B) 
                    : const Color(0xFFEF4444)).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (healthScore >= 80 
                  ? const Color(0xFF10B981) 
                  : healthScore >= 50 
                      ? const Color(0xFFF59E0B) 
                      : const Color(0xFFEF4444)).withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PhosphorIcon(
                    PhosphorIconsRegular.lightbulb,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Rekomendasi Manager',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                managerNote,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ).animate().fade(delay: 250.ms).slideY(begin: 0.1),

        const SizedBox(height: 24),
        
        // Summary Cards Section Header
        Text(
          'Ringkasan Keuangan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fade(delay: 280.ms),
        const SizedBox(height: 12),

        // 2x2 Grid of Financial Metric Cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.25,
          children: [
            _SummaryItemCard(
              title: 'Pemasukan',
              amount: state.totalIncome,
              icon: PhosphorIconsRegular.trendUp,
              color: AppColors.accent,
              isDark: isDark,
            ),
            _SummaryItemCard(
              title: 'Pengeluaran',
              amount: state.totalExpense,
              icon: PhosphorIconsRegular.trendDown,
              color: AppColors.alert,
              isDark: isDark,
            ),
            _SummaryItemCard(
              title: 'Arus Kas Bersih',
              amount: state.totalIncome - state.totalExpense,
              icon: PhosphorIconsRegular.arrowsLeftRight,
              color: (state.totalIncome - state.totalExpense) >= 0 
                  ? AppColors.accent 
                  : AppColors.alert,
              isDark: isDark,
              extraLabel: (state.totalIncome - state.totalExpense) >= 0 ? '🟢 SURPLUS' : '🔴 DEFISIT',
            ),
            _SummaryItemCard(
              title: 'Dana Simpanan',
              amount: state.savingGoal?.currentAmount ?? 0.0,
              icon: PhosphorIconsRegular.piggyBank,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
          ],
        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

        const SizedBox(height: 24),

        // Donut Chart
        if (sortedCategories.isNotEmpty && state.totalExpense > 0) ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alokasi Pengeluaran per Kategori', 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _buildPieSections(sortedCategories, state.totalExpense),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Legend
                ...sortedCategories.take(4).map((e) {
                  final pct = state.totalExpense > 0 ? (e.value / state.totalExpense) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(color: _getCategoryColor(e.key), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.key, style: Theme.of(context).textTheme.bodyMedium)),
                        Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

          if (expenses.isNotEmpty) ...[
            const SizedBox(height: 24),

            // Leaderboard - Top Spending & Largest Transactions
            Text(
              'Analisis Pengeluaran Terbesar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade(delay: 420.ms),
            const SizedBox(height: 12),

            // Top Spending Categories
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsRegular.trendDown,
                        color: AppColors.alert,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kategori Terboros (Top 3)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...sortedCategories.take(3).map((e) {
                    final pct = state.totalExpense > 0 ? (e.value / state.totalExpense) * 100 : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                CurrencyService.formatRupiah(e.value),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Linear progress bar matching the slice color
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (pct / 100).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(e.key),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fade(delay: 450.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Largest Transactions List
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsRegular.shoppingBagOpen,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Transaksi Terbesar (Top 3)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...top3Largest.map((tx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.alert.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const PhosphorIcon(
                                PhosphorIconsRegular.basket,
                                color: AppColors.alert,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.category ?? 'Jajanan',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  if (tx.note != null && tx.note!.isNotEmpty)
                                    Text(
                                      tx.note!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '-${CurrencyService.formatRupiah(tx.amount)}',
                              style: const TextStyle(
                                color: AppColors.alert,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ).animate().fade(delay: 480.ms).slideY(begin: 0.1),
          ],

          const SizedBox(height: 24),

          // Unified Action Center
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unified Action Center',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unduh atau bagikan laporan keuangan rilis premium dalam format berkas PDF.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isExporting ? null : onExportPdf,
                        icon: isExporting 
                            ? const SizedBox(
                                width: 18, height: 18, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const PhosphorIcon(PhosphorIconsRegular.filePdf, size: 18),
                        label: Text(
                          isExporting ? 'Mengekspor...' : 'Unduh PDF',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3B82F6),
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isExporting ? null : onSharePdf,
                        icon: const PhosphorIcon(PhosphorIconsRegular.shareFat, size: 18),
                        label: const Text(
                          'Bagikan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(List<MapEntry<String, double>> sortedCategories, double totalExpense) {
    return sortedCategories.map((e) {
      final pct = totalExpense > 0 ? (e.value / totalExpense) * 100 : 0.0;
      return PieChartSectionData(
        color: _getCategoryColor(e.key),
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final hash = category.hashCode;
    final colors = [AppColors.primary, AppColors.accent, AppColors.alert, const Color(0xFF3B82F6), const Color(0xFFF59E0B), const Color(0xFF8B5CF6)];
    return colors[hash % colors.length];
  }
}

class _SummaryItemCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isDark;
  final String? extraLabel;

  const _SummaryItemCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
    this.extraLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: PhosphorIcon(icon, color: color, size: 18),
              ),
              if (extraLabel != null)
                Text(
                  extraLabel!,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyService.formatRupiah(amount).replaceAll('Rp', ''),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerExportTab extends StatelessWidget {
  final DashboardState state;
  final bool isExporting;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;
  final VoidCallback? onSharePdf;
  final VoidCallback? onShareExcel;

  const _LedgerExportTab({
    required this.state,
    required this.isExporting,
    required this.onExportPdf,
    required this.onExportExcel,
    this.onSharePdf,
    this.onShareExcel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txList = List<TransactionModel>.from(state.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;

        if (isLandscape) {
          // ── Landscape / Tablet: side-by-side layout ──
          return Row(
            children: [
              // Left: Action panel
              SizedBox(
                width: 260,
                child: _ActionPanel(
                  isDark: isDark,
                  isExporting: isExporting,
                  onExportPdf: onExportPdf,
                  onExportExcel: onExportExcel,
                  onSharePdf: onSharePdf,
                  onShareExcel: onShareExcel,
                  totalTx: txList.length,
                  totalExpense: state.totalExpense,
                  totalIncome: state.totalIncome,
                ),
              ),
              Container(width: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
              // Right: Ledger
              Expanded(
                child: _LedgerList(txList: txList, isDark: isDark),
              ),
            ],
          );
        }

        // ── Portrait: stacked layout ──
        return Column(
          children: [
            // Export/Share action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  // Row 1: Export PDF + Excel
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Export PDF',
                          icon: PhosphorIconsRegular.filePdf,
                          color: AppColors.primary,
                          isDark: isDark,
                          onPressed: isExporting ? null : onExportPdf,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          label: 'Export Excel',
                          icon: PhosphorIconsRegular.fileXls,
                          color: AppColors.accent,
                          isDark: isDark,
                          onPressed: isExporting ? null : onExportExcel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: Share buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Bagikan PDF',
                          icon: PhosphorIconsRegular.shareFat,
                          color: const Color(0xFF3B82F6),
                          isDark: isDark,
                          onPressed: isExporting ? null : onSharePdf,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          label: 'Bagikan Excel',
                          icon: PhosphorIconsRegular.shareNetwork,
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                          onPressed: isExporting ? null : onShareExcel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 12),

            // Ledger list
            Expanded(child: _LedgerList(txList: txList, isDark: isDark)),
          ],
        );
      },
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final bool isDark;
  final bool isExporting;
  final VoidCallback onExportPdf;
  final VoidCallback onExportExcel;
  final VoidCallback? onSharePdf;
  final VoidCallback? onShareExcel;
  final int totalTx;
  final double totalExpense;
  final double totalIncome;

  const _ActionPanel({
    required this.isDark,
    required this.isExporting,
    required this.onExportPdf,
    required this.onExportExcel,
    required this.totalTx,
    required this.totalExpense,
    required this.totalIncome,
    this.onSharePdf,
    this.onShareExcel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aksi Laporan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '$totalTx transaksi tercatat',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          _ActionButton(label: 'Export PDF', icon: PhosphorIconsRegular.filePdf, color: AppColors.primary, isDark: isDark, onPressed: isExporting ? null : onExportPdf),
          const SizedBox(height: 10),
          _ActionButton(label: 'Export Excel', icon: PhosphorIconsRegular.fileXls, color: AppColors.accent, isDark: isDark, onPressed: isExporting ? null : onExportExcel),
          const SizedBox(height: 10),
          _ActionButton(label: 'Bagikan PDF', icon: PhosphorIconsRegular.shareFat, color: const Color(0xFF3B82F6), isDark: isDark, onPressed: isExporting ? null : onSharePdf),
          const SizedBox(height: 10),
          _ActionButton(label: 'Bagikan Excel', icon: PhosphorIconsRegular.shareNetwork, color: const Color(0xFF8B5CF6), isDark: isDark, onPressed: isExporting ? null : onShareExcel),
          const Spacer(),
          // Summary stats
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                _StatRow(label: 'Total Masuk', value: CurrencyService.formatRupiah(totalIncome), color: AppColors.accent),
                const SizedBox(height: 8),
                _StatRow(label: 'Total Keluar', value: CurrencyService.formatRupiah(totalExpense), color: AppColors.alert),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final PhosphorIconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.surfaceVariantDark : Colors.white,
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        icon: PhosphorIcon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}

class _LedgerList extends StatelessWidget {
  final List<TransactionModel> txList;
  final bool isDark;

  const _LedgerList({required this.txList, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (txList.isEmpty) {
      return NataEmptyState(
        icon: PhosphorIconsRegular.receipt,
        title: 'Belum Ada Transaksi',
        subtitle: 'Mulai catat pemasukan dan pengeluaran dari Dashboard.\nLaporan akan tampil di sini secara otomatis.',
        accentColor: AppColors.primary,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: txList.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          itemBuilder: (context, index) {
            final tx = txList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Date badge
                  Container(
                    width: 44,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (tx.isExpense ? AppColors.alert : AppColors.accent).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(tx.date),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: tx.isExpense ? AppColors.alert : AppColors.accent,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(tx.date),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: tx.isExpense ? AppColors.alert : AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.category ?? 'Tanpa Kategori',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (tx.note != null && tx.note!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            tx.note!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${tx.isExpense ? '-' : '+'}${CurrencyService.formatRupiah(tx.amount).replaceAll('Rp', 'Rp')}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: tx.isExpense ? AppColors.alert : AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(delay: Duration(milliseconds: 40 * (index % 10))).slideX(begin: 0.05, end: 0);
          },
        ),
      ),
    ).animate().fade(delay: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

