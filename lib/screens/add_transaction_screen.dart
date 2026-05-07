import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  _CatMeta(Color(0xFFF1F5F9), Color(0xFF475569), Icons.more_horiz_rounded,     'Lainnya'),
];

// ─── Screen bisa dipakai untuk Add & Edit ────────────────────────────────────
class AddTransactionScreen extends StatefulWidget {
  final Function(String, double, bool, String) addTx;
  final TransactionModel? editTx; // ← null = mode tambah, isi = mode edit

  const AddTransactionScreen({
    super.key,
    required this.addTx,
    this.editTx,
  });

  @override
  State<AddTransactionScreen> createState() => _State();
}

class _State extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _titleFocus = FocusNode();
  final _amountFocus= FocusNode();

  bool    _isIncome = true;
  bool    _isLoading= false;
  String? _selCat;

  late AnimationController _anim;

  bool get _isEditMode => widget.editTx != null;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250))
      ..forward();

    // Pre-fill data jika mode edit
    if (_isEditMode) {
      final tx = widget.editTx!;
      _titleCtrl.text  = tx.title;
      _amountCtrl.text = tx.amount.toStringAsFixed(0);
      _isIncome        = tx.isIncome;
      _selCat          = tx.category;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _amountCtrl.dispose();
    _titleFocus.dispose(); _amountFocus.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title  = _titleCtrl.text.trim();
    final amount = double.tryParse(
        _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));

    if (title.isEmpty || amount == null || amount <= 0) {
      _snack("Isi judul dan nominal dengan benar", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cat = _selCat ?? await AiService.detectCategory(title);

      if (_isEditMode) {
        // ── MODE EDIT ──────────────────────────────────────────────────────
        final updated = TransactionModel(
          id      : widget.editTx!.id,
          title   : title,
          amount  : amount,
          date    : widget.editTx!.date,
          isIncome: _isIncome,
          category: cat,
        );
        final ok = await TransactionService.update(updated);
        if (ok) {
          _snack("Transaksi berhasil diperbarui ✓");
          if (mounted) Navigator.pop(context, true); // return true = refresh
        } else {
          _snack("Gagal memperbarui transaksi", isError: true);
        }
      } else {
        // ── MODE TAMBAH ────────────────────────────────────────────────────
        final tx = TransactionModel(
          id      : DateTime.now().millisecondsSinceEpoch.toString(),
          title   : title,
          amount  : amount,
          date    : DateTime.now(),
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
    return Scaffold(
      backgroundColor: c.bgPage,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildToggle(context),
            const SizedBox(height: 24),
            _buildAmountField(context),
            const SizedBox(height: 20),
            _buildTitleField(context),
            const SizedBox(height: 24),
            _buildCatLabel(context),
            const SizedBox(height: 12),
            _buildCatGrid(context),
            const SizedBox(height: 32),
            _buildSubmitBtn(context),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [StaticColors.headerDeep, StaticColors.headerNavy, StaticColors.headerBlue],
        stops: [0.0, 0.45, 1.0],
      ),
    ),
    child: SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: StaticColors.white, size: 16),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          _isEditMode ? "Edit Transaksi" : "Tambah Transaksi",
          style: const TextStyle(color: StaticColors.white, fontSize: 18,
              fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ]),
    )),
  );

  Widget _buildToggle(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 52, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(color: const Color(0xFF1540A8).withOpacity(0.07),
            blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        _typeBtn(context, "Pemasukan",   true,  Icons.arrow_downward_rounded),
        _typeBtn(context, "Pengeluaran", false, Icons.arrow_upward_rounded),
      ]),
    );
  }

  Widget _typeBtn(BuildContext context, String label, bool isIncome, IconData icon) {
    final sel = _isIncome == isIncome;
    final activeBg = isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _isIncome = isIncome),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: sel ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: sel ? StaticColors.white : context.colors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            color: sel ? StaticColors.white : context.colors.textMuted,
            fontSize: 13, fontWeight: FontWeight.w600,
          )),
        ]),
      ),
    ));
  }

  Widget _buildAmountField(BuildContext context) {
    final accent = _isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;
    final bg     = _isIncome ? StaticColors.incomeLight : StaticColors.expenseLight;
    final border = _isIncome ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Nominal", style: TextStyle(color: accent, fontSize: 12,
            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text("Rp", style: TextStyle(color: accent, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _amountCtrl, focusNode: _amountFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: accent, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: TextStyle(color: accent.withOpacity(0.35), fontSize: 26, fontWeight: FontWeight.w800),
              border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _amountFocus.unfocus(),
          )),
        ]),
      ]),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.inputBorder),
        boxShadow: [BoxShadow(color: const Color(0xFF1540A8).withOpacity(0.05),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.edit_note_rounded, size: 15, color: StaticColors.headerBright),
          SizedBox(width: 6),
          Text("Judul Transaksi", style: TextStyle(color: StaticColors.headerBright,
              fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        ]),
        TextField(
          controller: _titleCtrl, focusNode: _titleFocus,
          style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: "cth: Makan siang, Gojek, Gaji…",
            hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
            border: InputBorder.none, isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_amountFocus),
        ),
      ]),
    );
  }

  Widget _buildCatLabel(BuildContext context) {
    final c = context.colors;
    return Row(children: [
      Text("Kategori", style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(width: 6),
      Text("(opsional — AI deteksi otomatis)",
          style: TextStyle(color: c.textMuted, fontSize: 11)),
    ]);
  }

  Widget _buildCatGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: _cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
      itemBuilder: (_, i) {
        final cat = _cats[i];
        final sel = _selCat == cat.label;
        return GestureDetector(
          onTap: () => setState(() => _selCat = sel ? null : cat.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: sel ? cat.fg : context.colors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? cat.fg : context.colors.inputBorder, width: sel ? 1.5 : 1),
              boxShadow: sel
                  ? [BoxShadow(color: cat.fg.withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 38, height: 38,
                decoration: BoxDecoration(
                    color: sel ? Colors.white.withOpacity(0.20) : cat.bg, shape: BoxShape.circle),
                child: Icon(cat.icon, size: 20, color: sel ? StaticColors.white : cat.fg),
              ),
              const SizedBox(height: 6),
              Text(cat.label, textAlign: TextAlign.center,
                style: TextStyle(color: sel ? StaticColors.white : context.colors.textSecondary,
                    fontSize: 10, fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildSubmitBtn(BuildContext context) {
    final btnColor = _isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;
    final glow     = _isIncome
        ? StaticColors.incomeGreen.withOpacity(0.35)
        : StaticColors.expenseRed.withOpacity(0.35);
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220), height: 56,
        decoration: BoxDecoration(
          color: btnColor, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: glow, blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Center(child: _isLoading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_isEditMode ? Icons.save_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(_isEditMode ? "Simpan Perubahan" : "Simpan Transaksi",
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            ]),
        ),
      ),
    );
  }
}