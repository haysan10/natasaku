import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/dev/mock_data_seeder.dart';
import '../../data/models/budget_mode.dart';
import '../../data/models/budget_period.dart';
import '../../data/models/saving_goal.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/utils/rupiah_input_formatter.dart';
import '../../core/theme/app_shadows.dart';
import '../../data/models/fixed_expense_item.dart';
import '../../core/services/currency_service.dart';
import '../../core/utils/nominal_input_validator.dart';

class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fundController = TextEditingController();
  final _fixedExpensesController = TextEditingController();
  final _savingAllocationController = TextEditingController();
  final _savingNameController = TextEditingController();
  final _savingTargetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 29));
  BudgetMode _mode = BudgetMode.normal;
  bool _saving = false;
  List<FixedExpenseItem> _fixedExpenseItems = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _fundController.addListener(_onControllerChanged);
    _fixedExpensesController.addListener(_onControllerChanged);
    _savingAllocationController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Future<void> _loadInitialData() async {
    final repo = ref.read(budgetRepositoryProvider);
    final items = await repo.loadFixedExpenseItems();
    setState(() {
      _fixedExpenseItems = items;
      _updateFixedExpensesTotal();
    });
  }

  void _updateFixedExpensesTotal() {
    final total = FixedExpenseItem.totalOf(_fixedExpenseItems);
    _fixedExpensesController.text = total > 0 ? NumberFormat('#,###', 'id_ID').format(total) : '';
  }

  void _addFixedExpenseItem(FixedExpenseItem item) {
    setState(() {
      _fixedExpenseItems.add(item);
      _updateFixedExpensesTotal();
    });
  }

  void _editFixedExpenseItem(FixedExpenseItem item) {
    setState(() {
      final index = _fixedExpenseItems.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _fixedExpenseItems[index] = item;
      }
      _updateFixedExpensesTotal();
    });
  }

  void _deleteFixedExpenseItem(String id) {
    setState(() {
      _fixedExpenseItems.removeWhere((i) => i.id == id);
      _updateFixedExpensesTotal();
    });
  }

  void _toggleFixedExpenseItem(String id) {
    setState(() {
      final index = _fixedExpenseItems.indexWhere((i) => i.id == id);
      if (index >= 0) {
        final item = _fixedExpenseItems[index];
        _fixedExpenseItems[index] = FixedExpenseItem(
          id: item.id,
          name: item.name,
          amount: item.amount,
          category: item.category,
          emoji: item.emoji,
          isActive: !item.isActive,
        );
      }
      _updateFixedExpensesTotal();
    });
  }

  int _parseAmount(String raw) {
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    final value = int.tryParse(normalized) ?? 0;
    return value < 0 ? 0 : value;
  }

  @override
  void dispose() {
    _fundController.removeListener(_onControllerChanged);
    _fixedExpensesController.removeListener(_onControllerChanged);
    _savingAllocationController.removeListener(_onControllerChanged);
    _fundController.dispose();
    _fixedExpensesController.dispose();
    _savingAllocationController.dispose();
    _savingNameController.dispose();
    _savingTargetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final fund = _parseAmount(_fundController.text);
    final fixed = _parseAmount(_fixedExpensesController.text);
    final allocation = _parseAmount(_savingAllocationController.text);

    final validation = NominalInputValidator.validateSetup(
      totalIncome: fund.round(),
      totalFixedExpense: fixed.round(),
      savingAllocation: allocation.round(),
      startDate: _startDate,
      endDate: _endDate,
    );

    if (validation['status'] == 'error') {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rencana Anggaran Tidak Valid! ⚠️'),
          content: Text(validation['message'] as String),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Perbaiki'),
            ),
          ],
        ),
      );
      return;
    }

    if (validation['status'] == 'warning') {
      HapticFeedback.heavyImpact();
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Perhatian Rencana Anggaran ⚠️'),
          content: Text(validation['message'] as String),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondaryLight),
              child: const Text('Batal & Perbaiki'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.alert),
              child: const Text('Yakin, Lanjutkan'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _saving = true);

    final savingName = _savingNameController.text.trim();
    final savingTarget = _parseAmount(_savingTargetController.text);

    final repo = ref.read(budgetRepositoryProvider);
    await repo.saveOnboardingComplete(true);
    await repo.saveFixedExpenseItems(_fixedExpenseItems);

    await repo.savePeriod(
      BudgetPeriod(
        id: 'active_period',
        startDate: _startDate,
        endDate: _endDate,
        flexibleFund: fund,
        fixedExpenses: fixed,
        monthlySavingAllocation: allocation,
        mode: _mode,
      ),
    );
    
    if (savingName.isNotEmpty && savingTarget > 0) {
      await repo.saveSavingGoal(
        SavingGoal(
          id: 'active_saving_goal',
          name: savingName,
          targetAmount: savingTarget,
          currentAmount: 0,
        ),
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    // Explicitly reload the dashboard provider state before navigating
    await ref.read(dashboardProvider.notifier).loadData();
    if (!mounted) return;
    context.go(AppRouter.dashboard);
  }

  Future<void> _seedMockData() async {
    setState(() => _saving = true);
    await MockDataSeeder.seed();
    await ref.read(budgetRepositoryProvider).saveOnboardingComplete(true);
    if (!mounted) return;
    setState(() => _saving = false);
    // Explicitly reload the dashboard provider state before navigating
    await ref.read(dashboardProvider.notifier).loadData();
    if (!mounted) return;
    context.go(AppRouter.dashboard);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;
    setState(() {
      if (isStart) {
        _startDate = selected;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = selected;
        if (_startDate.isAfter(_endDate)) {
          _startDate = _endDate;
        }
      }
    });
  }

  Future<void> _showAddEditFixedExpenseSheet([FixedExpenseItem? editingItem]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: editingItem?.name);
    final amountController = TextEditingController(
      text: editingItem != null
          ? NumberFormat('#,###', 'id_ID').format(editingItem.amount)
          : '',
    );
    FixedExpenseCategory selectedCategory = editingItem?.category ?? FixedExpenseCategory.lainnya;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<FixedExpenseItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            24, 
            24, 
            24, 
            MediaQuery.of(context).viewInsets.bottom + 32
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editingItem == null ? 'Tambah Tagihan Rutin' : 'Ubah Tagihan Rutin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Name field
                TextFormField(
                  controller: nameController,
                  autofocus: editingItem == null,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Nama Tagihan',
                    prefixIcon: PhosphorIconsRegular.pencil,
                    hintText: 'Contoh: Biaya Kos',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Nama tagihan wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category field
                DropdownButtonFormField<FixedExpenseCategory>(
                  initialValue: selectedCategory,
                  dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Kategori Tagihan',
                    prefixIcon: PhosphorIconsRegular.tag,
                  ),
                  items: FixedExpenseCategory.values.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text('${getCategoryEmoji(cat)}  ${getCategoryLabel(cat)}'),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    letterSpacing: 0.5,
                  ),
                  decoration: _buildInputDecoration(
                    labelText: 'Nominal (Rp)',
                    prefixIcon: PhosphorIconsRegular.money,
                    hintText: 'Masukkan nominal rupiah',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Nominal wajib diisi';
                    final parsed = _parseAmount(val);
                    if (parsed <= 0) return 'Nominal harus lebih dari Rp 0';
                    if (parsed > 999999999999) return 'Nominal terlalu besar';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final name = nameController.text.trim();
                            final amount = _parseAmount(amountController.text);
                            Navigator.pop(
                              context,
                              FixedExpenseItem(
                                id: editingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                amount: amount,
                                category: selectedCategory,
                                emoji: getCategoryEmoji(selectedCategory),
                                isActive: editingItem?.isActive ?? true,
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      if (editingItem == null) {
        _addFixedExpenseItem(result);
      } else {
        _editFixedExpenseItem(result);
      }
    }
  }

  Widget _buildBudgetPreview() {
    final fund = _parseAmount(_fundController.text);
    final fixed = _parseAmount(_fixedExpensesController.text);
    final saving = _parseAmount(_savingAllocationController.text);
    final flexible = fund - fixed - saving;

    if (fund == 0) return const SizedBox.shrink();

    final isNegative = flexible < 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isNegative
            ? AppColors.alert.withValues(alpha: 0.08)
            : AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNegative ? AppColors.alert.withValues(alpha: 0.3) : AppColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _PreviewRow('Dana Masuk', fund, color: AppColors.accent),
          _PreviewRow('Tagihan Tetap', -fixed, color: AppColors.alert),
          _PreviewRow('Tabungan', -saving, color: Colors.amber),
          const Divider(),
          _PreviewRow(
            isNegative ? '⚠️ Dana Minus!' : '✅ Dana Fleksibel',
            flexible,
            color: isNegative ? AppColors.alert : AppColors.accent,
            isBold: true,
          ),
          if (isNegative) ...[
            const SizedBox(height: 8),
            const Text(
              'Tagihan & tabunganmu melebihi pemasukan. Kurangi salah satunya.',
              style: TextStyle(color: AppColors.alert, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required String subtitle,
    required Widget child,
    required IconData icon,
    String? tooltipText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: AppShadows.card(isDark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: PhosphorIcon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'LANGKAH 0$step',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        if (tooltipText != null) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: tooltipText,
                            triggerMode: TooltipTriggerMode.tap,
                            showDuration: const Duration(seconds: 4),
                            child: Icon(
                              Icons.help_outline_rounded,
                              size: 18,
                              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: PhosphorIcon(prefixIcon, color: AppColors.primary, size: 22),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
      labelStyle: TextStyle(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.alert,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.alert,
          width: 2.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(AppRouter.dashboard);
            }
          },
        ),
        title: Text(
          'Atur Keuangan',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 60),
          physics: const BouncingScrollPhysics(),
          children: [
            // Gorgeous Premium Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.rocket_launch_outlined,
                    color: Colors.white,
                    size: 40,
                  ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(
                    'Ayo Buat Rencana! 🚀',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Isi form simpel ini agar NataSaku bisa menghitung jatah harianmu dengan akurat.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fade().slideY(begin: -0.1),
            
            // Step 1: Fund
            _buildStepCard(
              step: 1,
              title: 'Uang yang Bisa Dipakai',
              subtitle: 'Berapa uang yang kamu punya untuk dipakai bulan ini?',
              tooltipText: 'Total uang yang bebas kamu pakai bulan ini — setelah dikurangi tagihan rutin dan tabungan wajib.',
              icon: PhosphorIconsRegular.money,
              child: TextFormField(
                controller: _fundController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: 0.5,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Total Dana (Rp)',
                  prefixIcon: PhosphorIconsRegular.wallet,
                  hintText: 'Masukkan nominal rupiah',
                ),
                validator: (value) => NominalInputValidator.validateAmount(value ?? ''),
              ),
            ).animate().fade(delay: 150.ms).slideX(begin: 0.05),
            
            // Step 2: Period
            _buildStepCard(
              step: 2,
              title: 'Periode Waktu',
              subtitle: 'Dana di atas harus cukup untuk dipakai sampai tanggal berapa?',
              icon: PhosphorIconsRegular.calendar,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _pickDate(isStart: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const PhosphorIcon(PhosphorIconsRegular.calendarPlus, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mulai',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _startDate.toLocal().toString().split(' ').first,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: PhosphorIcon(PhosphorIconsRegular.arrowRight, color: AppColors.primary, size: 16),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _pickDate(isStart: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const PhosphorIcon(PhosphorIconsRegular.calendarCheck, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sampai',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _endDate.toLocal().toString().split(' ').first,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 200.ms).slideX(begin: 0.05),
            
            // Step 3: Fixed Monthly Expenses (Tagihan Rutin Bulanan)
            _buildStepCard(
              step: 3,
              title: 'Tagihan Rutin Bulanan',
              subtitle: 'Tambahkan semua tagihan tetapmu. NataSaku akan menjumlahkan otomatis.',
              tooltipText: 'Tagihan rutin bulanan seperti sewa kos, cicilan kendaraan, internet, air, listrik, dll.',
              icon: PhosphorIconsRegular.receipt,
              child: Column(
                children: [
                  Offstage(
                    child: TextFormField(
                      controller: _fixedExpensesController,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final parsed = NominalInputValidator.parseNominal(value);
                          if (parsed > 999999999999) return 'Nominal terlalu besar';
                        }
                        return null;
                      },
                    ),
                  ),
                  _FixedExpenseListBuilder(
                    items: _fixedExpenseItems,
                    onAdd: () => _showAddEditFixedExpenseSheet(),
                    onEdit: _showAddEditFixedExpenseSheet,
                    onDelete: _deleteFixedExpenseItem,
                    onToggle: _toggleFixedExpenseItem,
                  ),
                ],
              ),
            ).animate().fade(delay: 250.ms).slideX(begin: 0.05),
            
            // Step 4: Monthly Savings Allocation
            _buildStepCard(
              step: 4,
              title: 'Berapa Ingin Kamu Tabung?',
              subtitle: 'Berapa yang ingin kamu sisihkan untuk tabungan per bulan ini?',
              tooltipText: 'Berapa yang ingin kamu sisihkan setiap bulan. NataSaku akan mengamankan ini dulu sebelum menghitung jatah harianmu.',
              icon: PhosphorIconsRegular.vault,
              child: TextFormField(
                controller: _savingAllocationController,
                keyboardType: TextInputType.number,
                inputFormatters: [RupiahInputFormatter()],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: 0.5,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Tabungan Bulanan (Rp)',
                  prefixIcon: PhosphorIconsRegular.piggyBank,
                  hintText: 'Lewati jika belum ada tabungan wajib',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final parsed = NominalInputValidator.parseNominal(value);
                    if (parsed > 999999999999) return 'Nominal terlalu besar. Maksimum Rp 999.999.999.999';
                  }
                  return null;
                },
              ),
            ).animate().fade(delay: 300.ms).slideX(begin: 0.05),

            // Real-time Budget Preview
            _buildBudgetPreview(),
            
            // Step 5: Savings Goal
            _buildStepCard(
              step: 5,
              title: 'Target Tabungan',
              subtitle: 'Opsional. Punya impian/barang impian yang ingin segera Anda miliki?',
              icon: PhosphorIconsRegular.star,
              child: Column(
                children: [
                  TextFormField(
                    controller: _savingNameController,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: _buildInputDecoration(
                      labelText: 'Nama impian',
                      prefixIcon: PhosphorIconsRegular.sparkle,
                      hintText: 'Contoh: Laptop Kerja Baru',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _savingTargetController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [RupiahInputFormatter()],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: _buildInputDecoration(
                      labelText: 'Nominal target',
                      prefixIcon: PhosphorIconsRegular.target,
                      hintText: 'Masukkan nominal target tabungan',
                    ),
                    validator: (value) {
                      final hasName = _savingNameController.text.trim().isNotEmpty;
                      final hasAmount = (value ?? '').trim().isNotEmpty;
                      if (hasName && NominalInputValidator.parseNominal(value ?? '') <= 0) {
                        return 'Nominal target wajib diisi';
                      }
                      if (!hasName && hasAmount) {
                        return 'Isi nama impian tabungan Anda';
                      }
                      if (hasAmount) {
                        final fund = _parseAmount(_fundController.text);
                        final valErr = NominalInputValidator.validateSavingGoal(
                          targetAmount: NominalInputValidator.parseNominal(value ?? ''),
                          totalIncome: fund.round(),
                        );
                        if (valErr != null && valErr.contains('terlalu besar')) return valErr;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ).animate().fade(delay: 350.ms).slideX(begin: 0.05),
            
            // Step 6: Mode
            _buildStepCard(
              step: 6,
              title: 'Gaya Pemakaian',
              subtitle: 'Pilih mode budget untuk menyesuaikan tingkat kehematan pengeluaran Anda.',
              icon: PhosphorIconsRegular.sliders,
              child: DropdownButtonFormField<BudgetMode>(
                initialValue: _mode,
                icon: const PhosphorIcon(PhosphorIconsRegular.caretDown, color: AppColors.primary),
                dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                items: BudgetMode.values
                    .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(
                          _modeLabel(mode),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        )))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _mode = value ?? BudgetMode.normal),
                decoration: _buildInputDecoration(
                  labelText: 'Pilih Mode Budget',
                  prefixIcon: PhosphorIconsRegular.speedometer,
                ),
              ),
            ).animate().fade(delay: 300.ms).slideX(begin: 0.05),
            
            const SizedBox(height: 16),
            
            // Premium Primary Action Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.button(),
              ),
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: _saving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const PhosphorIcon(PhosphorIconsFill.checkCircle, size: 20),
                label: Text(
                  _saving ? 'MENYIMPAN RENCANA...' : 'Siap! Mulai Atur Keuanganku 🚀',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ).animate().fade(delay: 350.ms).scale(curve: Curves.easeOutBack),
            
            const SizedBox(height: 18),
            
            Text(
              'Rencana ini bisa Anda perbarui/ubah kapan saja secara bebas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 12,
              ),
            ).animate().fade(delay: 400.ms),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Dev / Testing Shortcut (🧪 Muat Data Tes)
            OutlinedButton.icon(
              onPressed: _saving ? null : _seedMockData,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.science_outlined, size: 20),
              label: const Text(
                '🧪  MUAT DATA TES (UMR JAKARTA)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 13,
                ),
              ),
            ).animate().fade(delay: 450.ms),
            
            const SizedBox(height: 8),
            Text(
              'Menyediakan data realistis gaji UMR Jakarta terpopulasi lengkap untuk uji coba seluruh visualisasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(BudgetMode mode) {
    switch (mode) {
      case BudgetMode.normal: return 'Normal (Bebas Belanja)';
      case BudgetMode.hemat: return 'Hemat (Tahan Tabungan)';
      case BudgetMode.krisis: return 'Mode Darurat';
    }
  }
}

// ── Category Helper Methods ───────────────────────────────────────────

String getCategoryEmoji(FixedExpenseCategory cat) {
  switch (cat) {
    case FixedExpenseCategory.sewakos: return '🏠';
    case FixedExpenseCategory.cicilanKendaraan: return '🚗';
    case FixedExpenseCategory.cicilanRumah: return '🏡';
    case FixedExpenseCategory.asuransi: return '🛡️';
    case FixedExpenseCategory.internet: return '📶';
    case FixedExpenseCategory.listrik: return '⚡';
    case FixedExpenseCategory.air: return '💧';
    case FixedExpenseCategory.gas: return '🔥';
    case FixedExpenseCategory.streaming: return '📺';
    case FixedExpenseCategory.gymKesehatan: return '💪';
    case FixedExpenseCategory.sekolahKuliah: return '📚';
    case FixedExpenseCategory.tabunganWajib: return '🏦';
    case FixedExpenseCategory.lainnya: return '➕';
  }
}

String getCategoryLabel(FixedExpenseCategory cat) {
  switch (cat) {
    case FixedExpenseCategory.sewakos: return 'Sewa/Kos';
    case FixedExpenseCategory.cicilanKendaraan: return 'Cicilan Kendaraan';
    case FixedExpenseCategory.cicilanRumah: return 'Cicilan Rumah';
    case FixedExpenseCategory.asuransi: return 'Asuransi';
    case FixedExpenseCategory.internet: return 'Internet/WiFi';
    case FixedExpenseCategory.listrik: return 'Listrik';
    case FixedExpenseCategory.air: return 'Air';
    case FixedExpenseCategory.gas: return 'Gas';
    case FixedExpenseCategory.streaming: return 'Streaming';
    case FixedExpenseCategory.gymKesehatan: return 'Gym/Kesehatan';
    case FixedExpenseCategory.sekolahKuliah: return 'Sekolah/Kuliah';
    case FixedExpenseCategory.tabunganWajib: return 'Tabungan Wajib';
    case FixedExpenseCategory.lainnya: return 'Lainnya';
  }
}

// ── Preview Widget Helpers ───────────────────────────────────────────

class _PreviewRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final bool isBold;

  const _PreviewRow(this.label, this.amount, {required this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 14 : 13,
            ),
          ),
          Text(
            (amount < 0 ? '-' : '') + CurrencyService.formatRupiah(amount.abs()),
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: isBold ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Multi Fixed Expense List Widgets ─────────────────────────────────

class _FixedExpenseListBuilder extends StatelessWidget {
  final List<FixedExpenseItem> items;
  final VoidCallback onAdd;
  final ValueChanged<FixedExpenseItem> onEdit;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onToggle;

  const _FixedExpenseListBuilder({
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final total = FixedExpenseItem.totalOf(items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.alert.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long, color: AppColors.alert, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Total: ${CurrencyService.formatRupiah(total)}',
                  style: const TextStyle(color: AppColors.alert, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...items.map((item) => _FixedExpenseTile(
          item: item,
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item.id),
          onToggle: () => onToggle(item.id),
        )),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah Tagihan'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _FixedExpenseTile extends StatelessWidget {
  final FixedExpenseItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _FixedExpenseTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: item.isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isActive ? AppColors.alert.withValues(alpha: 0.2) : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(CurrencyService.formatRupiah(item.amount)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch.adaptive(
                value: item.isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (_) => onToggle(),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.alert),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
