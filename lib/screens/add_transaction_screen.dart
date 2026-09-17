import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/ai_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class _CatMeta {
  final Color bg, fg;
  final IconData icon;
  final String label;
  const _CatMeta(this.bg, this.fg, this.icon, this.label);
}

const _cats = <_CatMeta>[
  _CatMeta(Color(0xFFFFF3E0), Color(0xFFE65100), Icons.restaurant_rounded,    'Makanan'),
  _CatMeta(Color(0xFFE3F2FD), Color(0xFF1565C0), Icons.directions_car_rounded, 'Transport'),
  _CatMeta(Color(0xFFF3E5F5), Color(0xFF6A1B9A), Icons.movie_rounded,          'Hiburan'),
  _CatMeta(Color(0xFFE8F5E9), Color(0xFF2E7D32), Icons.favorite_rounded,       'Kesehatan'),
  _CatMeta(Color(0xFFFCE4EC), Color(0xFFC62828), Icons.shopping_bag_rounded,   'Belanja'),
  _CatMeta(Color(0xFFEDE7F6), Color(0xFF4527A0), Icons.school_rounded,         'Pendidikan'),
  _CatMeta(Color(0xFFE0F7FA), Color(0xFF006064), Icons.home_rounded,           'Rumah'),
  _CatMeta(Color(0xFFFEF3C7), Color(0xFFD97706), Icons.payments_rounded,       'Income'),
  _CatMeta(Color(0xFFF1F5F9), Color(0xFF475569), Icons.more_horiz_rounded,     'Lainnya'),
];

class AddTransactionScreen extends StatefulWidget {
  final Function(String, double, bool, String) addTx;
  final TransactionModel? editTx;

  const AddTransactionScreen({
    super.key,
    required this.addTx,
    this.editTx,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _titleFocus = FocusNode();
  final _amountFocus= FocusNode();

  bool      _isIncome     = false; // Default to Pengeluaran for daily ease
  bool      _isLoading    = false;
  String?   _selCat;
  String?   _aiSuggestion;
  DateTime  _selectedDate = DateTime.now();

  late AnimationController _anim;

  bool get _isEditMode => widget.editTx != null;

  static const List<int> _quickAmounts = [10000, 25000, 50000, 100000, 250000, 500000];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..forward();

    if (_isEditMode) {
      final tx = widget.editTx!;
      _titleCtrl.text  = tx.title;
      _amountCtrl.text = tx.amount.toStringAsFixed(0);
      _isIncome        = tx.isIncome;
      _selCat          = tx.category;
      _selectedDate    = tx.date;
    }

    _titleCtrl.addListener(_onTitleChanged);
  }

  void _onTitleChanged() async {
    final t = _titleCtrl.text.trim();
    if (t.length >= 3 && _selCat == null) {
      final detected = await AiService.detectCategory(t);
      if (mounted && detected != 'Lainnya') {
        setState(() => _aiSuggestion = detected);
      }
    } else if (t.isEmpty && _aiSuggestion != null) {
      setState(() => _aiSuggestion = null);
    }
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onTitleChanged);
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _titleFocus.dispose();
    _amountFocus.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _addQuickAmount(int delta) {
    HapticFeedback.lightImpact();
    final current = double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    final total = current + delta;
    _amountCtrl.text = total.toStringAsFixed(0);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: StaticColors.headerBright,
              brightness: Theme.of(context).brightness,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _selectedDate = DateTime(
          picked.year, picked.month, picked.day,
          now.hour, now.minute, now.second,
        );
      });
    }
  }

  Future<void> _submit() async {
    final title  = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));

    if (title.isEmpty || amount == null || amount <= 0) {
      _snack("Isi judul dan nominal dengan benar", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cat = _selCat ?? await AiService.detectCategory(title);

      if (_isEditMode) {
        final updated = TransactionModel(
          id      : widget.editTx!.id,
          title   : title,
          amount  : amount,
          date    : _selectedDate,
          isIncome: _isIncome,
          category: cat,
        );
        final ok = await TransactionService.update(updated);
        if (ok) {
          _snack("Transaksi berhasil diperbarui ✓");
          if (mounted) Navigator.pop(context, true);
        } else {
          _snack("Gagal memperbarui transaksi", isError: true);
        }
      } else {
        final tx = TransactionModel(
          id      : DateTime.now().millisecondsSinceEpoch.toString(),
          title   : title,
          amount  : amount,
          date    : _selectedDate,
          isIncome: _isIncome,
          category: cat,
        );
        final ok = await TransactionService.add(tx);
        if (ok) {
          widget.addTx(title, amount, _isIncome, cat);
          _snack("Transaksi berhasil disimpan ✓");
          if (mounted) Navigator.pop(context, true);
        } else {
          _snack("Gagal menyimpan transaksi", isError: true);
        }
      }
    } catch (_) {
      _snack("Gagal terhubung ke server", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? StaticColors.expenseDeep : StaticColors.incomeDeep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dateLabel = DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: c.bgPage,
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Transaksi" : "Tambah Transaksi",
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _anim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Income / Expense Segmented Control ─────────────────────────
              _buildTypeSelector(c),
              const SizedBox(height: 20),

              // ── Nominal Card ──────────────────────────────────────────────
              _buildAmountInputCard(c),
              const SizedBox(height: 16),

              // ── Quick Amounts ─────────────────────────────────────────────
              _buildQuickAmountRow(c),
              const SizedBox(height: 22),

              // ── Judul & Kategori ──────────────────────────────────────────
              _buildFormFields(c, dateLabel),
              const SizedBox(height: 32),

              // ── Save Button ───────────────────────────────────────────────
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(DynamicColors c) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isIncome = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isIncome ? StaticColors.expenseRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isIncome
                      ? [BoxShadow(color: StaticColors.expenseRed.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: !_isIncome ? Colors.white : c.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Pengeluaran",
                      style: TextStyle(
                        color: !_isIncome ? Colors.white : c.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isIncome = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isIncome ? StaticColors.incomeGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isIncome
                      ? [BoxShadow(color: StaticColors.incomeGreen.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: _isIncome ? Colors.white : c.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Pemasukan",
                      style: TextStyle(
                        color: _isIncome ? Colors.white : c.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputCard(DynamicColors c) {
    final activeColor = _isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.cardBorder),
        boxShadow: [
          BoxShadow(color: activeColor.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nominal Transaksi",
            style: TextStyle(color: c.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Rp",
                style: TextStyle(
                  color: activeColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  focusNode: _amountFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: "0",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (_amountCtrl.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    _amountCtrl.clear();
                    setState(() {});
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountRow(DynamicColors c) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _quickAmounts.map((amt) {
          final label = amt >= 1000000
              ? "+${(amt / 1000000).toStringAsFixed(0)}jt"
              : "+${(amt / 1000).toStringAsFixed(0)}rb";

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(label),
              labelStyle: TextStyle(
                color: c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: c.bgCard,
              side: BorderSide(color: c.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onPressed: () => _addQuickAmount(amt),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormFields(DynamicColors c, String dateLabel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Judul ──
          Text("Judul Transaksi", style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: c.bgInput,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.inputBorder),
            ),
            child: TextField(
              controller: _titleCtrl,
              focusNode: _titleFocus,
              style: TextStyle(color: c.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: "Contoh: Makan siang rendang, Bensin",
                hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.edit_note_rounded, color: c.textMuted, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),

          // ── AI Suggestion Chip ──
          if (_aiSuggestion != null && _selCat == null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selCat = _aiSuggestion;
                  _aiSuggestion = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Rekomendasi AI: $_aiSuggestion (Tap untuk pilih)",
                      style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // ── Tanggal Transaksi ──
          Text("Tanggal Transaksi", style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: c.bgInput,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.inputBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: c.textMuted, size: 19),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Text(
                    "Ubah",
                    style: TextStyle(color: StaticColors.headerBright, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Kategori ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Kategori", style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
              if (_selCat != null)
                GestureDetector(
                  onTap: () => setState(() => _selCat = null),
                  child: const Text("Deteksi Otomatis", style: TextStyle(color: StaticColors.headerBright, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(c),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(DynamicColors c) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _cats.map((cat) {
        final isSel = _selCat == cat.label;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selCat = isSel ? null : cat.label;
              _aiSuggestion = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? cat.fg : c.bgInput,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? cat.fg : c.inputBorder,
                width: isSel ? 1.5 : 1.0,
              ),
              boxShadow: isSel
                  ? [BoxShadow(color: cat.fg.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 16,
                  color: isSel ? Colors.white : cat.fg,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: isSel ? Colors.white : c.textPrimary,
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [StaticColors.headerBlue, StaticColors.headerBright],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: StaticColors.headerBright.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isEditMode ? "Simpan Perubahan" : "Simpan Transaksi",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}