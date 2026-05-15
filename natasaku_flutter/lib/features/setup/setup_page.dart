import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/models/budget_mode.dart';
import '../../data/models/budget_period.dart';
import '../../data/repositories/budget_repository.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fundController = TextEditingController();
  final BudgetRepository _repo = BudgetRepository(LocalStorage());

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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await _repo.savePeriod(
      BudgetPeriod(
        id: 'active_period',
        startDate: _startDate,
        endDate: _endDate,
        flexibleFund: _parseAmount(_fundController.text),
        mode: _mode,
      ),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai Atur Uang'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          children: [
            Text(
              'Langkah 1: Dana Fleksibel',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berapa sisa uangmu yang bebas dipakai (di luar tagihan, cicilan, dan tabungan)?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fundController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                labelText: 'Total Dana Bebas (Rp)',
                labelStyle: const TextStyle(fontSize: 16),
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              validator: (value) {
                final parsed = _parseAmount(value ?? '');
                if (parsed <= 0) {
                  return 'Nominal belum diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Langkah 2: Periode Waktu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dana di atas harus cukup sampai tanggal berapa?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _pickDate(isStart: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Mulai',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate.toLocal().toString().split(' ').first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _pickDate(isStart: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Sampai',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate.toLocal().toString().split(' ').first,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Langkah 3: Gaya Pemakaian',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'NataSaku akan menyesuaikan perhitungan jatah harianmu.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BudgetMode>(
              initialValue: _mode,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: BudgetMode.values
                  .map((mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(
                        _modeLabel(mode),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _mode = value ?? BudgetMode.normal),
              decoration: const InputDecoration(
                labelText: 'Pilih Mode',
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_rounded),
              label: Text(_saving ? 'Menyimpan...' : 'Simpan & Mulai'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kamu bisa menyesuaikan angka ini nanti jika ada perubahan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _modeLabel(BudgetMode mode) {
    switch (mode) {
      case BudgetMode.normal:
        return 'Normal';
      case BudgetMode.hemat:
        return 'Hemat';
      case BudgetMode.krisis:
        return 'Krisis';
    }
  }
}
