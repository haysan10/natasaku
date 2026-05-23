import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/currency_service.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/dev/mock_data_seeder.dart';
import '../../data/models/budget_mode.dart';
import '../../data/models/budget_period.dart';
import '../../data/models/saving_goal.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/utils/nominal_formatter.dart';
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

  double _parseAmount(String raw) {
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    final value = double.tryParse(normalized) ?? 0;
    return value.isFinite ? value : 0;
  }

  @override
  void dispose() {
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

  Widget _buildStepCard({
    required int step,
    required String title,
    required String subtitle,
    required Widget child,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.borderDark.withOpacity(0.5) : AppColors.borderLight.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
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
                        color: AppColors.primary.withOpacity(0.1),
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
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
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
      fillColor: isDark ? AppColors.surfaceVariantDark.withOpacity(0.3) : AppColors.surfaceVariantLight.withOpacity(0.4),
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
                    color: AppColors.primary.withOpacity(0.3),
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
                      color: Colors.white.withOpacity(0.9),
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
              title: 'Dana Fleksibel',
              subtitle: 'Berapa sisa uangmu yang bebas dipakai (di luar tagihan, cicilan, dan tabungan)?',
              icon: PhosphorIconsRegular.money,
              child: TextFormField(
                controller: _fundController,
                keyboardType: TextInputType.number,
                inputFormatters: [NominalFormatter()],
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
                          color: isDark ? AppColors.surfaceVariantDark.withOpacity(0.3) : AppColors.surfaceVariantLight.withOpacity(0.4),
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
                          color: isDark ? AppColors.surfaceVariantDark.withOpacity(0.3) : AppColors.surfaceVariantLight.withOpacity(0.4),
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
            
            // Step 3: Fixed Monthly Expenses
            _buildStepCard(
              step: 3,
              title: 'Pengeluaran Tetap',
              subtitle: 'Berapa total tagihan rutin bulananmu? (kos, listrik, wifi, cicilan, dll)',
              icon: PhosphorIconsRegular.receipt,
              child: TextFormField(
                controller: _fixedExpensesController,
                keyboardType: TextInputType.number,
                inputFormatters: [NominalFormatter()],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: 0.5,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Tagihan Tetap (Rp)',
                  prefixIcon: PhosphorIconsRegular.lightning,
                  hintText: 'Opsional — bisa 0',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final parsed = NominalInputValidator.parseNominal(value);
                    if (parsed > 999999999999) return 'Nominal terlalu besar. Maksimum Rp 999.999.999.999';
                  }
                  return null;
                },
              ),
            ).animate().fade(delay: 250.ms).slideX(begin: 0.05),
            
            // Step 4: Monthly Savings Allocation
            _buildStepCard(
              step: 4,
              title: 'Alokasi Tabungan',
              subtitle: 'Berapa yang ingin kamu sisihkan untuk tabungan per bulan ini?',
              icon: PhosphorIconsRegular.vault,
              child: TextFormField(
                controller: _savingAllocationController,
                keyboardType: TextInputType.number,
                inputFormatters: [NominalFormatter()],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  letterSpacing: 0.5,
                ),
                decoration: _buildInputDecoration(
                  labelText: 'Tabungan Bulanan (Rp)',
                  prefixIcon: PhosphorIconsRegular.piggyBank,
                  hintText: 'Opsional — bisa 0',
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
                    inputFormatters: [NominalFormatter()],
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
                value: _mode,
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
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
                  _saving ? 'MENYIMPAN RENCANA...' : 'SIMPAN & MULAI BERSAKU!',
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
      case BudgetMode.krisis: return 'Krisis (Batas Terendah)';
    }
  }
}
