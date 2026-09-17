import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../theme/app_colors.dart';
import 'add_transaction_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback? onNavigateToTx;
  final ValueChanged<int>? onNavigateToTab;
  final Future<void> Function()? onRefresh;
  final Function(String, double, bool, String)? addTx;

  const HomeScreen({
    super.key,
    required this.transactions,
    this.onNavigateToTx,
    this.onNavigateToTab,
    this.onRefresh,
    this.addTx,
  });

  double get _income  => transactions.where((t) =>  t.isIncome).fold(0.0, (s, t) => s + t.amount);
  double get _expense => transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

  String _rp(double v) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(v);

  List<TransactionModel> get _recent {
    final l = transactions.toList()..sort((a, b) => b.date.compareTo(a.date));
    return l.length > 5 ? l.sublist(0, 5) : l;
  }

  int _notifCount() {
    if (transactions.isEmpty) return 0;
    int c = 0;
    final ratio = _income > 0 ? (_expense / _income) * 100 : 0.0;
    if (ratio > 60) c++;
    if (_income - _expense < 0) c++;
    final now = DateTime.now();
    if (transactions.where((t) =>
        t.date.year == now.year && t.date.month == now.month && t.date.day == now.day)
        .isEmpty) {
      c++;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final inc    = _income, exp = _expense, bal = inc - exp;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: c.bgPage,
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        color: StaticColors.headerBright,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, bal, inc, exp)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 22),
                  _buildQuickStats(context, inc, exp),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    context,
                    "Transaksi Terkini",
                    "Lihat semua",
                    onSeeAll: onNavigateToTx,
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionList(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double balance, double income, double expense) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [StaticColors.headerDeep, StaticColors.headerNavy, StaticColors.headerBlue],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -40, right: -30, child: _glow(160, StaticColors.headerBright.withValues(alpha: 0.18))),
          Positioned(top: 30, right: 50, child: _glow(80, StaticColors.accentCyan.withValues(alpha: 0.10))),
          Positioned(bottom: -20, left: -20, child: _glow(120, StaticColors.glowBlue.withValues(alpha: 0.12))),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(color: StaticColors.white70, fontSize: 13, letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dateStr,
                            style: const TextStyle(color: StaticColors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      _notifBtn(context),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: balance >= 0 ? StaticColors.incomeGreen : StaticColors.expenseRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total Saldo Aktif",
                          style: TextStyle(
                            color: StaticColors.white.withValues(alpha: 0.90),
                            fontSize: 12,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _rp(balance),
                    style: const TextStyle(
                      color: StaticColors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(child: _statTile("Pemasukan", income, true)),
                      const SizedBox(width: 12),
                      Expanded(child: _statTile("Pengeluaran", expense, false)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double s, Color c) =>
      Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _notifBtn(BuildContext context) {
    final count = _notifCount();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationScreen(transactions: transactions),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 21),
          ),
          if (count > 0)
            Positioned(
              top: -4, right: -4,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(color: StaticColors.expenseRed, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    count > 9 ? "9+" : "$count",
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statTile(String label, double amount, bool isIncome) {
    final pill      = isIncome ? StaticColors.incomeGreen.withValues(alpha: 0.20) : StaticColors.expenseRed.withValues(alpha: 0.20);
    final iconColor = isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;
    final icon      = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: pill, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: StaticColors.white70, fontSize: 11, letterSpacing: 0.3)),
                const SizedBox(height: 2),
                Text(
                  _rp(amount),
                  style: const TextStyle(color: StaticColors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1540A8).withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionBtn(
            context,
            icon: Icons.add_circle_rounded,
            color: StaticColors.headerBright,
            bgColor: const Color(0xFFEFF6FF),
            label: "Tambah",
            onTap: () async {
              final res = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    addTx: addTx ?? (t, a, i, c) {},
                  ),
                ),
              );
              if (res == true && onRefresh != null) {
                await onRefresh!();
              }
            },
          ),
          _actionBtn(
            context,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFF3E8FF),
            label: "Riwayat",
            onTap: onNavigateToTx,
          ),
          _actionBtn(
            context,
            icon: Icons.insights_rounded,
            color: const Color(0xFF0D9488),
            bgColor: const Color(0xFFCCFBF1),
            label: "Insight",
            onTap: () => onNavigateToTab?.call(2),
          ),
          _actionBtn(
            context,
            icon: Icons.smart_toy_rounded,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFEF3C7),
            label: "Tanya AI",
            onTap: () => onNavigateToTab?.call(3),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String label,
    VoidCallback? onTap,
  }) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, double income, double expense) {
    final c = context.colors;
    final total = income + expense;
    final ir = total > 0 ? (income / total).clamp(0.0, 1.0) : 0.0;
    final er = total > 0 ? (expense / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1540A8).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ringkasan Bulan Ini", style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
              Text(
                total > 0 ? "${(er * 100).toStringAsFixed(0)}% Pengeluaran" : "0%",
                style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _progressRow(
            context,
            "Pemasukan",
            ir,
            _rp(income),
            StaticColors.incomeGreen,
            StaticColors.incomeLight,
            Icons.trending_up_rounded,
            StaticColors.incomeDeep,
          ),
          const SizedBox(height: 16),
          _progressRow(
            context,
            "Pengeluaran",
            er,
            _rp(expense),
            StaticColors.expenseRed,
            StaticColors.expenseLight,
            Icons.trending_down_rounded,
            StaticColors.expenseDeep,
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
    BuildContext context,
    String label,
    double value,
    String amount,
    Color bar,
    Color track,
    IconData icon,
    Color iconColor,
  ) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: track, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(amount, style: TextStyle(color: iconColor, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  color: bar,
                  backgroundColor: track,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? action, {VoidCallback? onSeeAll}) {
    final c = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
        if (action != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: StaticColors.headerBright.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: const TextStyle(color: StaticColors.headerBright, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, color: StaticColors.headerBright, size: 10),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final c = context.colors;
    if (_recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.cardBorder),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 44, color: c.textMuted),
              const SizedBox(height: 12),
              Text("Belum ada transaksi", style: TextStyle(color: c.textMuted, fontSize: 14)),
              const SizedBox(height: 6),
              Text("Tap tombol Tambah untuk mencatat sekarang", style: TextStyle(color: c.textMuted.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1540A8).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: List.generate(_recent.length, (i) {
          return _txTile(context, _recent[i], i == _recent.length - 1);
        }),
      ),
    );
  }

  Widget _txTile(BuildContext context, TransactionModel tx, bool isLast) {
    final c     = context.colors;
    final isInc = tx.isIncome;
    final dateFormatted = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(tx.date);

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetailSheet(context, tx),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isInc ? StaticColors.incomeLight : StaticColors.expenseLight,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    isInc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isInc ? StaticColors.incomeGreen : StaticColors.expenseRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${tx.category} • $dateFormatted",
                        style: TextStyle(color: c.textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isInc ? '+' : '-'} ${_rp(tx.amount)}",
                  style: TextStyle(
                    color: isInc ? StaticColors.incomeDeep : StaticColors.expenseDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: c.divider, indent: 74),
      ],
    );
  }

  void _showDetailSheet(BuildContext context, TransactionModel tx) {
    final c     = context.colors;
    final isInc = tx.isIncome;

    showModalBottomSheet(
      context: context,
      backgroundColor: c.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: c.cardBorder, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: isInc ? StaticColors.incomeLight : StaticColors.expenseLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInc ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isInc ? StaticColors.incomeGreen : StaticColors.expenseRed,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${isInc ? '+' : '-'} ${_rp(tx.amount)}",
                style: TextStyle(
                  color: isInc ? StaticColors.incomeDeep : StaticColors.expenseDeep,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(tx.title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.bgPage,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.cardBorder),
                ),
                child: Column(
                  children: [
                    _detailRow(c, "Jenis", isInc ? "Pemasukan" : "Pengeluaran"),
                    const SizedBox(height: 10),
                    _detailRow(c, "Kategori", tx.category),
                    const SizedBox(height: 10),
                    _detailRow(c, "Waktu", DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(tx.date)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: StaticColors.expenseRed.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: c.bgCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            title: Text("Hapus Transaksi", style: TextStyle(color: c.textPrimary)),
                            content: Text("Yakin ingin menghapus \"${tx.title}\"?", style: TextStyle(color: c.textSecondary)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Hapus", style: TextStyle(color: StaticColors.expenseRed, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await TransactionService.delete(tx.id);
                          if (onRefresh != null) await onRefresh!();
                        }
                      },
                      icon: const Icon(Icons.delete_outline_rounded, color: StaticColors.expenseRed, size: 18),
                      label: const Text("Hapus", style: TextStyle(color: StaticColors.expenseRed, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StaticColors.headerBright,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddTransactionScreen(
                              addTx: addTx ?? (t, a, i, c) {},
                              editTx: tx,
                            ),
                          ),
                        );
                        if (res == true && onRefresh != null) {
                          await onRefresh!();
                        }
                      },
                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                      label: const Text("Edit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(DynamicColors c, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: c.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return "Selamat Pagi ☀️";
    if (h < 15) return "Selamat Siang 🌤";
    if (h < 18) return "Selamat Sore 🌇";
    return "Selamat Malam 🌙";
  }
}