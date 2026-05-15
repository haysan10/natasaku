import 'package:flutter/material.dart';

class TransactionDraft {
  const TransactionDraft({
    required this.amount,
    required this.isExpense,
    required this.date,
    this.category,
    this.note,
  });

  final double amount;
  final bool isExpense;
  final DateTime date;
  final String? category;
  final String? note;
}

const List<String> nataCategories = <String>[
  'Makan',
  'Transport',
  'Belanja',
  'Tagihan',
  'Keluarga',
  'Hiburan',
  'Kesehatan',
  'Lainnya',
];

Future<TransactionDraft?> showTransactionEntrySheet(
  BuildContext context, {
  bool initialExpense = true,
  double? initialAmount,
  String? initialCategory,
  String? initialNote,
}) {
  final amountController = TextEditingController(
    text: initialAmount == null || initialAmount <= 0
        ? ''
        : initialAmount.toStringAsFixed(
            initialAmount == initialAmount.roundToDouble() ? 0 : 2),
  );
  final noteController = TextEditingController(text: initialNote ?? '');
  var isExpense = initialExpense;
  var pickedDate = DateTime.now();
  String? selectedCategory = initialCategory;
  var showNotes = (initialNote?.trim().isNotEmpty ?? false);

  double parseAmount(String raw) {
    final normalized = raw.replaceAll('.', '').replaceAll(',', '.').trim();
    final value = double.tryParse(normalized) ?? 0;
    return value.isFinite ? value : 0;
  }

  InputDecoration fieldDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  return showModalBottomSheet<TransactionDraft>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catat Detail',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pakai form ini kalau kamu ingin isi transaksi lebih lengkap.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Pengeluaran'),
                        icon: Tooltip(
                          message: 'Pengeluaran',
                          child: Icon(Icons.arrow_upward),
                        ),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Pemasukan'),
                        icon: Tooltip(
                          message: 'Pemasukan',
                          child: Icon(Icons.savings_outlined),
                        ),
                      ),
                    ],
                    selected: {isExpense},
                    onSelectionChanged: (selection) {
                      setModalState(() => isExpense = selection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: fieldDecoration(
                        label: 'Nominal', hint: 'Contoh: 25.000'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: fieldDecoration(label: 'Kategori (opsional)'),
                    items: nataCategories
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: pickedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() => pickedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: fieldDecoration(label: 'Tanggal'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}',
                            ),
                          ),
                          const Icon(Icons.calendar_month),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!showNotes)
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() => showNotes = true);
                      },
                      icon: const Icon(Icons.add_comment_outlined),
                      label: const Text('+ Tambah catatan'),
                    ),
                  if (showNotes)
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: fieldDecoration(label: 'Catatan (opsional)'),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: ButtonStyle(
                        overlayColor: WidgetStateProperty.all(
                          Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      onPressed: () {
                        final amount = parseAmount(amountController.text);
                        if (amount <= 0) return;
                        Navigator.pop(
                          context,
                          TransactionDraft(
                            amount: amount,
                            isExpense: isExpense,
                            date: pickedDate,
                            category: selectedCategory,
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                          ),
                        );
                      },
                      child: const Text('Simpan Detail'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
