import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../theme/app_colors.dart';
import 'add_transaction_screen.dart';

class _CatStyle {
  final Color bg, fg, bar;
  final IconData icon;
  const _CatStyle(this.bg, this.fg, this.bar, this.icon);
}

const _catMap = <String, _CatStyle>{
  'Makanan'   : _CatStyle(Color(0xFFFFF3E0), Color(0xFFE65100), Color(0xFFFB923C), Icons.restaurant_rounded),
  'Transport' : _CatStyle(Color(0xFFE3F2FD), Color(0xFF1565C0), Color(0xFF3B82F6), Icons.directions_car_rounded),
  'Hiburan'   : _CatStyle(Color(0xFFF3E5F5), Color(0xFF6A1B9A), Color(0xFFA855F7), Icons.movie_rounded),
  'Belanja'   : _CatStyle(Color(0xFFFCE4EC), Color(0xFFC62828), Color(0xFFEF4444), Icons.shopping_bag_rounded),
  'Kesehatan' : _CatStyle(Color(0xFFE8F5E9), Color(0xFF2E7D32), Color(0xFF22C55E), Icons.favorite_rounded),
  'Pendidikan': _CatStyle(Color(0xFFEDE7F6), Color(0xFF4527A0), Color(0xFF8B5CF6), Icons.school_rounded),
  'Rumah'     : _CatStyle(Color(0xFFE0F7FA), Color(0xFF006064), Color(0xFF06B6D4), Icons.home_rounded),
};
_CatStyle _catOf(String? cat) => _catMap[cat] ??
    const _CatStyle(Color(0xFFF1F5F9), Color(0xFF475569), Color(0xFF94A3B8), Icons.label_rounded);

// ─── Filter state ─────────────────────────────────────────────────────────────
enum _TxFilter { all, income, expense }

class TransactionScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(String, double, bool, String) addTx;

  const TransactionScreen({
    super.key,
    required this.transactions,
    required this.addTx,
  });

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _searchCtrl = TextEditingController();

  _TxFilter _filter      = _TxFilter.all;
  String    _searchQuery = '';
  String?   _catFilter;
  bool      _showSearch  = false;

  String _rp(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  double get _income  => widget.transactions.where((t) =>  t.isIncome).fold(0, (s, t) => s + t.amount);
  double get _expense => widget.transactions.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);

  // ── Filtered & searched list ───────────────────────────────────────────────
  List<TransactionModel> get _filtered {
    var list = widget.transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Filter type
    if (_filter == _TxFilter.income)  list = list.where((t) =>  t.isIncome).toList();
    if (_filter == _TxFilter.expense) list = list.where((t) => !t.isIncome).toList();

    // Filter category
    if (_catFilter != null) list = list.where((t) => t.category == _catFilter).toList();

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.title.toLowerCase().contains(q) ||
          (t.category ?? '').toLowerCase().contains(q)).toList();
    }

    return list;
  }

  // ── Group by date ──────────────────────────────────────────────────────────
  List<_TxGroup> _groupByDate(List<TransactionModel> list) {
    final map = <String, List<TransactionModel>>{};
    for (final tx in list) {
      final k = _dateLabel(tx.date);
      map.putIfAbsent(k, () => []).add(tx);
    }
    return map.entries.map((e) => _TxGroup(e.key, e.value)).toList();
  }

  String _dateLabel(DateTime date) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);
    if (d == today) return "Hari Ini";
    if (d == today.subtract(const Duration(days: 1))) return "Kemarin";
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  // ── Get unique categories ──────────────────────────────────────────────────
  List<String> get _availableCategories {
    return widget.transactions
        .map((t) => t.category ?? 'Lainnya')
        .toSet()
        .toList()
      ..sort();
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> _deleteTx(TransactionModel tx) async {
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: c.bgCard,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: StaticColors.expenseLight, shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, color: StaticColors.expenseRed, size: 26),
            ),
            const SizedBox(height: 16),
            Text("Hapus Transaksi?",
                style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "\"${tx.title}\" akan dihapus permanen.",
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.bgPage, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.cardBorder),
                  ),
                  child: Center(child: Text("Batal",
                      style: TextStyle(color: c.textSecondary, fontWeight: FontWeight.w600))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: StaticColors.expenseRed, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: StaticColors.expenseRed.withOpacity(0.35),
                        blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Center(child: Text("Hapus",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );

    if (ok == true) {
      final success = await TransactionService.delete(tx.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success ? "Transaksi dihapus" : "Gagal menghapus"),
          backgroundColor: success ? StaticColors.incomeDeep : StaticColors.expenseDeep,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        if (success) {
          // Reload dari parent
          await widget.addTx('__reload__', 0, true, '');
        }
      }
    }
  }

  // ── Edit ──────────────────────────────────────────────────────────────────
  Future<void> _editTx(TransactionModel tx) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          addTx: widget.addTx,
          editTx: tx, // ← pass transaksi yang mau diedit
        ),
      ),
    );
    if (result == true && mounted) {
      await widget.addTx('__reload__', 0, true, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final filtered = _filtered;
    final grouped  = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: c.bgPage,

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildFilterBar(context)),
          if (_showSearch)
            SliverToBoxAdapter(child: _buildSearchBar(context)),
          if (filtered.isEmpty)
            SliverFillRemaining(child: _buildEmpty(context))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildGroup(ctx, grouped[i]),
                  childCount: grouped.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [StaticColors.headerDeep, StaticColors.headerNavy, StaticColors.headerBlue],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(top: -30, right: -20,
            child: _glow(140, StaticColors.headerBright.withOpacity(0.17))),
        Positioned(bottom: -10, left: 0,
            child: _glow(100, StaticColors.glowBlue.withOpacity(0.12))),
        SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Transaksi",
                  style: TextStyle(color: StaticColors.white, fontSize: 20,
                      fontWeight: FontWeight.w800, letterSpacing: 0.2)),
              Row(children: [
                // Search button
                GestureDetector(
                  onTap: () => setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) { _searchQuery = ''; _searchCtrl.clear(); }
                  }),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _showSearch
                          ? Colors.white.withOpacity(0.25)
                          : Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(Icons.search_rounded, color: StaticColors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                // 🔥 Tombol tambah transaksi di header
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(addTx: widget.addTx),
                      ),
                    );
                    if (result == true && mounted) {
                      await widget.addTx('__reload__', 0, true, '');
                    }
                  },
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.add_rounded, color: StaticColors.white, size: 20),
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _statCard("Pemasukan",   _income,  true)),
              const SizedBox(width: 12),
              Expanded(child: _statCard("Pengeluaran", _expense, false)),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _glow(double s, Color c) => Container(
      width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _statCard(String label, double amount, bool isIncome) {
    final pill      = isIncome ? StaticColors.incomeGreen.withOpacity(0.18) : StaticColors.expenseRed.withOpacity(0.18);
    final iconColor = isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;
    final icon      = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(children: [
        Container(width: 34, height: 34,
            decoration: BoxDecoration(color: pill, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: StaticColors.white70, fontSize: 11, letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(_rp(amount),
              style: const TextStyle(color: StaticColors.white, fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  // ── Filter bar ────────────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context) {
    final c = context.colors;
    return Container(
      color: c.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          // Type filters
          _filterChip(context, "Semua",      _filter == _TxFilter.all,     () => setState(() { _filter = _TxFilter.all; _catFilter = null; })),
          const SizedBox(width: 8),
          _filterChip(context, "Pemasukan",  _filter == _TxFilter.income,  () => setState(() { _filter = _TxFilter.income; _catFilter = null; })),
          const SizedBox(width: 8),
          _filterChip(context, "Pengeluaran",_filter == _TxFilter.expense, () => setState(() { _filter = _TxFilter.expense; _catFilter = null; })),
          const SizedBox(width: 8),

          // Divider
          Container(width: 1, height: 24, color: c.cardBorder, margin: const EdgeInsets.symmetric(horizontal: 4)),
          const SizedBox(width: 8),

          // Category filters
          ..._availableCategories.map((cat) {
            final style = _catOf(cat);
            final sel   = _catFilter == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _catFilter = sel ? null : cat;
                  _filter    = _TxFilter.all;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? style.fg : c.bgCard,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: sel ? style.fg : c.cardBorder),
                    boxShadow: sel ? [BoxShadow(color: style.fg.withOpacity(0.25),
                        blurRadius: 8, offset: const Offset(0, 2))] : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(style.icon, size: 12, color: sel ? Colors.white : style.fg),
                    const SizedBox(width: 5),
                    Text(cat, style: TextStyle(
                      color: sel ? Colors.white : c.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w600,
                    )),
                  ]),
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? StaticColors.headerBright : c.bgCard,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? StaticColors.headerBright : c.cardBorder),
          boxShadow: selected ? [BoxShadow(color: StaticColors.headerBright.withOpacity(0.25),
              blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : c.textSecondary,
          fontSize: 12, fontWeight: FontWeight.w600,
        )),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: c.bgCard, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: StaticColors.headerBright.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: const Color(0xFF1540A8).withOpacity(0.07),
              blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Icon(Icons.search_rounded, color: c.textMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _searchCtrl,
            style: TextStyle(color: c.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: "Cari transaksi…",
              hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
              border: InputBorder.none, isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          )),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() { _searchQuery = ''; _searchCtrl.clear(); }),
              child: Icon(Icons.close_rounded, color: c.textMuted, size: 18),
            ),
        ]),
      ),
    );
  }

  // ── Grouped list ──────────────────────────────────────────────────────────
  Widget _buildGroup(BuildContext context, _TxGroup group) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Row(children: [
          Text(group.label, style: TextStyle(color: c.textSecondary, fontSize: 12,
              fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: c.divider, thickness: 1)),
          const SizedBox(width: 8),
          Text("${group.txs.length} transaksi",
              style: TextStyle(color: c.textMuted, fontSize: 10)),
        ]),
      ),
      Container(
        decoration: BoxDecoration(
          color: c.bgCard, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.cardBorder),
          boxShadow: [BoxShadow(color: const Color(0xFF1540A8).withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Column(children: List.generate(group.txs.length, (i) {
          final tx     = group.txs[i];
          final isLast = i == group.txs.length - 1;
          return _txTile(context, tx, isLast);
        })),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _txTile(BuildContext context, TransactionModel tx, bool isLast) {
    final c    = context.colors;
    final isInc= tx.isIncome;
    final cat  = _catOf(tx.category);

    return Column(children: [
      // Swipe to delete/edit
      Dismissible(
        key: Key(tx.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            await _deleteTx(tx);
          } else {
            await _editTx(tx);
          }
          return false; // jangan remove dari list — biar reload dari server
        },
        background: _swipeBg(context, isEdit: true),
        secondaryBackground: _swipeBg(context, isEdit: false),
        child: GestureDetector(
          onLongPress: () => _showActionSheet(context, tx),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              Container(width: 46, height: 46,
                decoration: BoxDecoration(color: cat.bg, borderRadius: BorderRadius.circular(13)),
                child: Icon(cat.icon, color: cat.fg, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tx.title,
                    style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  _badge(tx.category ?? "Lainnya", cat.bg, cat.fg),
                  const SizedBox(width: 6),
                  _badge(
                    isInc ? "Pemasukan" : "Pengeluaran",
                    isInc ? StaticColors.incomeLight : StaticColors.expenseLight,
                    isInc ? StaticColors.incomeDeep  : StaticColors.expenseDeep,
                  ),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("${isInc ? '+' : '–'} ${_rp(tx.amount)}",
                    style: TextStyle(
                      color: isInc ? StaticColors.incomeDeep : StaticColors.expenseDeep,
                      fontSize: 13, fontWeight: FontWeight.w700,
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(DateFormat('HH:mm').format(tx.date),
                      style: TextStyle(color: c.textMuted, fontSize: 11)),
                ),
              ]),
            ]),
          ),
        ),
      ),
      if (!isLast) Divider(height: 1, thickness: 1, color: c.divider, indent: 76),
    ]);
  }

  Widget _swipeBg(BuildContext context, {required bool isEdit}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isEdit ? const Color(0xFFEFF6FF) : StaticColors.expenseLight,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isEdit) ...[
          Icon(Icons.edit_rounded, color: StaticColors.headerBright, size: 20),
          const SizedBox(width: 6),
          const Text("Edit", style: TextStyle(color: StaticColors.headerBright,
              fontSize: 13, fontWeight: FontWeight.w700)),
        ] else ...[
          const Text("Hapus", style: TextStyle(color: StaticColors.expenseRed,
              fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          const Icon(Icons.delete_outline_rounded, color: StaticColors.expenseRed, size: 20),
        ],
      ]),
    );
  }

  // ── Action sheet (long press) ─────────────────────────────────────────────
  void _showActionSheet(BuildContext context, TransactionModel tx) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: c.cardBorder,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(tx.title, style: TextStyle(color: c.textPrimary, fontSize: 15,
              fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text("${tx.isIncome ? '+' : '–'} ${_rp(tx.amount)}",
              style: TextStyle(
                color: tx.isIncome ? StaticColors.incomeDeep : StaticColors.expenseDeep,
                fontSize: 13, fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 20),
          _sheetBtn(context, Icons.edit_rounded, StaticColors.headerBright,
              const Color(0xFFEFF6FF), "Edit Transaksi", () {
            Navigator.pop(context);
            _editTx(tx);
          }),
          const SizedBox(height: 10),
          _sheetBtn(context, Icons.delete_outline_rounded, StaticColors.expenseRed,
              StaticColors.expenseLight, "Hapus Transaksi", () {
            Navigator.pop(context);
            _deleteTx(tx);
          }),
        ]),
      ),
    );
  }

  Widget _sheetBtn(BuildContext context, IconData icon, Color fg, Color bg,
      String label, VoidCallback onTap) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: c.bgPage, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.cardBorder),
        ),
        child: Row(children: [
          const SizedBox(width: 16),
          Container(width: 34, height: 34,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: fg, size: 18)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Widget _buildEmpty(BuildContext context) {
    final c = context.colors;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 80, height: 80,
          decoration: BoxDecoration(color: c.bgCard, shape: BoxShape.circle,
              border: Border.all(color: c.cardBorder)),
          child: Icon(Icons.receipt_long_outlined, size: 36, color: c.textMuted)),
      const SizedBox(height: 16),
      Text(
        _searchQuery.isNotEmpty || _catFilter != null || _filter != _TxFilter.all
            ? "Tidak ada transaksi yang cocok"
            : "Belum ada transaksi",
        style: TextStyle(color: c.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Text(
        _searchQuery.isNotEmpty || _catFilter != null || _filter != _TxFilter.all
            ? "Coba ubah filter atau kata kunci"
            : "Ketuk + untuk menambahkan",
        style: TextStyle(color: c.textMuted, fontSize: 13),
      ),
    ]));
  }
}

class _TxGroup {
  final String label;
  final List<TransactionModel> txs;
  const _TxGroup(this.label, this.txs);
}