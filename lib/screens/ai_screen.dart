import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../services/financial_analytics_service.dart';
import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
class AiScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  const AiScreen({super.key, required this.transactions});
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, String>> messages = [];
  bool _isTyping = false;

  final _chips = [
    {'label': '📊 Analisis',   'prompt': 'Tolong analisis kondisi keuangan aku'},
    {'label': '💡 Tips Hemat', 'prompt': 'Berikan tips menghemat uang'},
    {'label': '⚠️ Cek Boros', 'prompt': 'Apakah pengeluaran aku boros?'},
    {'label': '📋 Saran',      'prompt': 'Berikan saran keuangan untuk aku'},
    {'label': '💰 Saldo',      'prompt': 'Berapa saldo aku sekarang?'},
  ];

  // ── Financial data ────────────────────────────────────────────────────────
  Map<String, dynamic> get _fin {
    double inc = 0, exp = 0;
    final catMap = <String, double>{};
    for (final tx in widget.transactions) {
      if (tx.isIncome) { inc += tx.amount; }
      else { exp += tx.amount; catMap[tx.category] = (catMap[tx.category] ?? 0) + tx.amount; }
    }
    final sorted = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return {
      'income': inc, 'expense': exp, 'balance': inc - exp,
      'ratio': inc > 0 ? (exp / inc) * 100 : 0.0,
      'total': widget.transactions.length,
      'categories': sorted,
      'isEmpty': widget.transactions.isEmpty,
    };
  }

  String _rp(double v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000)    return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp ${v.toStringAsFixed(0)}';
  }

  Future<String> _reply(String input) async {
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(1000)));
    final t = input.toLowerCase();
    final d = _fin;
    if (d['isEmpty'] == true) return "Belum ada transaksi tercatat 📭\n\nTambahkan beberapa transaksi dulu ya!";
    if (_has(t, ['saldo','balance','berapa uang']))     return _saldo(d);
    if (_has(t, ['analisis','analisa','kondisi']))      return _analisis(d);
    if (_has(t, ['boros','irit','pengeluaran besar']))  return _boros(d);
    if (_has(t, ['tips','hemat','menghemat']))          return _tips(d);
    if (_has(t, ['saran','rekomendasi','sebaiknya']))   return _saran(d);
    if (_has(t, ['pemasukan','income','gaji']))         return _income(d);
    if (_has(t, ['pengeluaran','expense','keluar']))    return _expense(d);
    if (_has(t, ['kategori','terbesar','terbanyak']))   return _kategori(d);
    if (_has(t, ['investasi','nabung','tabungan']))     return _investasi(d);
    if (_has(t, ['halo','hai','hi','hello']))           return "Halo! 👋 Aku AI Financial Assistant kamu.\n\nAku bisa bantu analisis keuangan, tips hemat, dan saran investasi.\n\nMau mulai dari mana? 😊";
    if (_has(t, ['terima kasih','makasih','thanks']))   return "Sama-sama! 😊 Semangat kelola keuangannya ya! 💪";
    return "Hmm, aku kurang paham 🤔\n\nCoba tanya soal:\n• Kondisi saldo\n• Analisis pengeluaran\n• Tips hemat\n• Saran investasi";
  }

  bool _has(String t, List<String> kw) => kw.any((k) => t.contains(k));

  String _saldo(d) { final b = d['balance'] as double; return "Kondisi saldo kamu:\n\n💰 Saldo: ${_rp(b)} ${b >= 0 ? '🟢' : '🔴'}\n📈 Pemasukan: ${_rp(d['income'])}\n📉 Pengeluaran: ${_rp(d['expense'])}\n\n${b >= 0 ? 'Saldo positif! Sisihkan sebagian untuk tabungan 💪' : 'Saldo minus, yuk evaluasi pengeluaran 🙏'}"; }
  String _analisis(d) { final r = d['ratio'] as double; final cats = d['categories'] as List; final status = r <= 50 ? '🟢 Sangat Sehat' : r <= 70 ? '🟡 Cukup Sehat' : r <= 90 ? '🟠 Perlu Perhatian' : '🔴 Kritis'; final advice = r <= 50 ? 'Pertimbangkan investasi.' : r <= 70 ? 'Masih aman, terus hemat.' : r <= 90 ? 'Mulai kurangi pengeluaran.' : 'Segera potong pengeluaran!'; final top = cats.isNotEmpty ? '\n\n📌 Terbesar: ${cats.first.key} (${_rp(cats.first.value)})' : ''; return "📊 Analisis:\n\nStatus: $status\n💵 Pemasukan: ${_rp(d['income'])}\n💸 Pengeluaran: ${_rp(d['expense'])}\n💰 Saldo: ${_rp(d['balance'])}\n📊 Rasio: ${r.toStringAsFixed(1)}%$top\n\n💡 $advice"; }
  String _boros(d) { final r = d['ratio'] as double; if (r <= 50) return "Hemat banget! 🎉\n\nRasio ${r.toStringAsFixed(1)}% — jauh di bawah 70%.\n💡 Manfaatkan sisa ${_rp(d['balance'])} untuk investasi!"; if (r <= 70) return "Masih wajar 👍\n\nRasio ${r.toStringAsFixed(1)}% — zona aman.\n💡 Tekan sedikit lagi!"; if (r <= 90) return "Mulai tinggi ⚠️\n\nRasio ${r.toStringAsFixed(1)}% — lewati 70%.\n💡 Review pengeluaran sekarang."; return "Cukup boros 🔴\n\nRasio ${r.toStringAsFixed(1)}%\n\nCoba metode 50/30/20:\n• 50% kebutuhan\n• 30% keinginan\n• 20% tabungan"; }
  String _tips(d) { final cats = d['categories'] as List; final extra = cats.isNotEmpty ? "\n\nTerbesar di ${cats.first.key}:\n• Catat tiap pengeluaran\n• Set budget maksimal\n• Cari alternatif lebih murah" : ""; return "💡 Tips Hemat:\n\n1. 📝 Catat semua pengeluaran\n2. 🛒 Buat daftar belanja dulu\n3. ☕ Kurangi jajan di luar\n4. 📱 Audit langganan\n5. 💰 Sisihkan 20% saat gajian$extra"; }
  String _saran(d) { final r = d['ratio'] as double; final b = d['balance'] as double; final main = r > 80 ? 'Prioritas: kurangi pengeluaran dulu.' : b > 500000 ? 'Saldo bagus! Mulai reksa dana.' : 'Bangun dana darurat 3x pengeluaran.'; return "📋 Saran:\n\n$main\n\n1. 🎯 Tetapkan target tabungan\n2. 📊 Review tiap minggu\n3. 🏦 Pisahkan rekening\n4. 📈 Mulai investasi Rp10rb"; }
  String _income(d) => "Pemasukan:\n\n📈 Total: ${_rp(d['income'])}\n📊 Dari ${d['total']} transaksi";
  String _expense(d) { final cats = d['categories'] as List; final detail = cats.isNotEmpty ? "\n\nTop kategori:\n${cats.take(3).map((e) => '  • ${e.key}: ${_rp(e.value)}').join('\n')}" : ""; return "Pengeluaran:\n\n📉 Total: ${_rp(d['expense'])}\n📊 Rasio: ${(d['ratio'] as double).toStringAsFixed(1)}%$detail"; }
  String _kategori(d) { final cats = d['categories'] as List; if (cats.isEmpty) return "Belum ada data kategori 📭"; final medals = ['🥇','🥈','🥉']; final list = cats.take(3).toList().asMap().entries.map((e) => "${medals[e.key]} ${e.value.key}: ${_rp(e.value.value)}").join('\n'); return "Kategori terbesar:\n\n$list"; }
  String _investasi(d) { final r = d['ratio'] as double; final b = d['balance'] as double; if (r > 85) return "Stabilkan dulu pengeluaran 🙏\n\nRasio ${r.toStringAsFixed(1)}% masih tinggi.\n\n1. Kurangi pengeluaran\n2. Bangun dana darurat\n3. Baru investasi"; final hint = b > 100000 ? "Saldo ${_rp(b)} cukup untuk mulai reksa dana." : "Mulai dari Rp10.000 pun bisa!"; return "💹 Investasi:\n\n$hint\n\n1. 🏦 Deposito\n2. 📈 Reksa dana\n3. 🏛️ SBN/ORI\n\n🎯 Mulai sekarang!"; }

  void _send([String? text]) async {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty || _isTyping) return;
    setState(() { messages.add({'role': 'user', 'text': msg}); _isTyping = true; });
    _ctrl.clear();
    _scrollToBottom();
    final res = await _reply(msg);
    setState(() { messages.add({'role': 'ai', 'text': res}); _isTyping = false; });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPage,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: messages.isEmpty ? _buildEmpty(context) : _buildList(context)),
        _buildInput(context),
      ]),
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
        Positioned(top: -30, right: -15,
            child: _glow(130, StaticColors.headerBright.withValues(alpha: 0.17))),
        Positioned(top: 20, right: 55,
            child: _glow(55, StaticColors.accentCyan.withValues(alpha: 0.10))),
        SafeArea(bottom: false, child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Row(children: [
            // 🔥 Claude-like logo
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                boxShadow: [BoxShadow(
                    color: StaticColors.headerBright.withValues(alpha: 0.30),
                    blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: const Center(child: const SizedBox(
                width: 26, height: 26,
                child: const CustomPaint(painter: const _ClaudeLogo(color: Colors.white)),
              )),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Cashly AI", style: TextStyle(color: StaticColors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
              SizedBox(height: 2),
              Text("Financial Assistant", style: TextStyle(color: StaticColors.white70, fontSize: 11)),
            ])),
            messages.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6,
                          decoration: const BoxDecoration(color: StaticColors.incomeGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      const Text("Online", style: TextStyle(color: StaticColors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                    ]),
                  )
                : GestureDetector(
                    onTap: () => setState(() => messages.clear()),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: StaticColors.white, size: 17),
                    ),
                  ),
          ]),
        )),
      ]),
    );
  }

  Widget _glow(double s, Color c) => Container(
      width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    final c     = context.colors;
    final score = FinancialAnalyticsService.calculateScore(widget.transactions);
    final Color scoreColor = score.total >= 85 ? StaticColors.incomeGreen
        : score.total >= 70 ? const Color(0xFF3B82F6)
        : score.total >= 55 ? const Color(0xFFF59E0B)
        : score.total >= 40 ? const Color(0xFFF97316)
        : StaticColors.expenseRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(children: [
        // Banner card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [StaticColors.headerNavy, StaticColors.headerBlue],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
                color: StaticColors.headerBlue.withValues(alpha: 0.28),
                blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(children: [
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(child: const SizedBox(width: 32, height: 32,
                  child: const CustomPaint(painter: const _ClaudeLogo(color: Colors.white)))),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Halo! Aku siap bantu 👋",
                  style: TextStyle(color: StaticColors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text("Tanyakan apa saja soal keuanganmu",
                  style: TextStyle(color: StaticColors.white70, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),

        // Financial Score mini
        if (widget.transactions.isNotEmpty)
          GestureDetector(
            onTap: () => _send("Analisis kondisi keuangan aku secara lengkap"),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.bgCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scoreColor.withValues(alpha: 0.25)),
                boxShadow: [BoxShadow(color: const Color(0xFF1540A8).withValues(alpha: 0.05),
                    blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Row(children: [
                Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: scoreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text("${score.total}",
                      style: TextStyle(color: scoreColor, fontSize: 20,
                          fontWeight: FontWeight.w900))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Financial Score • ${score.grade}",
                      style: TextStyle(color: c.textPrimary, fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(score.label, style: TextStyle(color: scoreColor,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(score.advice, style: TextStyle(color: c.textMuted, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Container(width: 26, height: 26,
                    decoration: BoxDecoration(color: c.bgPage, borderRadius: BorderRadius.circular(7)),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 11, color: c.textMuted)),
              ]),
            ),
          ),

        Align(alignment: Alignment.centerLeft,
            child: Text("Mulai dari sini", style: TextStyle(
                color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
        const SizedBox(height: 12),

        ...[
          (Icons.analytics_outlined,            StaticColors.headerBright,  const Color(0xFFEFF6FF), 'Analisis Keuangan', 'Kondisi finansial secara menyeluruh',    'Analisis Keuangan'),
          (Icons.lightbulb_outline_rounded,      const Color(0xFFB45309),    const Color(0xFFFFFBEB), 'Tips Menghemat',    'Cara cerdas kelola pengeluaran',          'Tips Hemat'),
          (Icons.trending_up_rounded,            StaticColors.incomeDeep,    StaticColors.incomeLight,'Saran Investasi',   'Mulai investasi dari langkah kecil',      'Saran Investasi'),
          (Icons.account_balance_wallet_outlined,const Color(0xFF7C3AED),    const Color(0xFFF5F3FF), 'Cek Saldo',         'Lihat kondisi saldo & rasio pengeluaran', 'Saldo'),
        ].map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _send(e.$6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: c.bgCard, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.cardBorder),
                boxShadow: [BoxShadow(
                    color: const Color(0xFF1540A8).withValues(alpha: 0.05),
                    blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: e.$3, borderRadius: BorderRadius.circular(11)),
                  child: Icon(e.$1, color: e.$2, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.$4, style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(e.$5, style: TextStyle(color: c.textMuted, fontSize: 11)),
                ])),
                Container(width: 26, height: 26,
                  decoration: BoxDecoration(color: c.bgPage, borderRadius: BorderRadius.circular(7)),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 11, color: c.textMuted),
                ),
              ]),
            ),
          ),
        )),
      ]),
    );
  }

  // ── Chat list ─────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == messages.length) return _typing(context);
        return _bubble(context, messages[i]);
      },
    );
  }

  Widget _bubble(BuildContext context, Map<String, String> msg) {
    final c = context.colors;
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [StaticColors.headerNavy, StaticColors.headerBlue],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(9),
              ),
              // 🔥 Claude logo di avatar chat
              child: const Center(child: const SizedBox(
                width: 16, height: 16,
                child: const CustomPaint(painter: const _ClaudeLogo(color: Colors.white)),
              )),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: msg['text']!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Pesan disalin ke clipboard ✓"),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                gradient: isUser ? const LinearGradient(
                    colors: [StaticColors.headerBlue, StaticColors.headerBright],
                    begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: isUser ? null : c.bgCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: c.cardBorder),
                boxShadow: [BoxShadow(
                  color: isUser ? StaticColors.headerBright.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isUser ? 12 : 8, offset: const Offset(0, 3),
                )],
              ),
              child: Text(msg['text']!, style: TextStyle(
                  fontSize: 13, color: isUser ? Colors.white : c.textPrimary, height: 1.55)),
            ),
          )),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [StaticColors.headerBlue, StaticColors.headerBright],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.person_rounded, size: 15, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typing(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [StaticColors.headerNavy, StaticColors.headerBlue],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Center(child: const SizedBox(
            width: 16, height: 16,
            child: const CustomPaint(painter: const _ClaudeLogo(color: Colors.white)),
          )),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: c.bgCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: c.cardBorder),
          ),
          child: Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _Dot(delay: Duration(milliseconds: i * 150)))),
        ),
      ]),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────
  Widget _buildInput(BuildContext context) {
    final c = context.colors;
    return Container(
      color: c.bgCard,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Divider(height: 1, thickness: 1, color: c.divider),
        const SizedBox(height: 10),
        SizedBox(height: 32, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _send(_chips[i]['prompt']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: StaticColors.headerBright.withValues(alpha: 0.25)),
              ),
              child: Text(_chips[i]['label']!, style: const TextStyle(
                  color: StaticColors.headerBright, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        )),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.only(
              left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 12),
          child: Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: c.bgInput,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: StaticColors.headerBright.withValues(alpha: 0.20), width: 1.5),
              ),
              child: TextField(
                controller: _ctrl,
                style: TextStyle(color: c.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tanya soal keuangan kamu…',
                  hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
                  border: InputBorder.none, isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _send(),
                maxLines: null,
              ),
            )),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [StaticColors.headerBlue, StaticColors.headerBright],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: StaticColors.headerBright.withValues(alpha: 0.35),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }
}

// ─── Claude-like Logo Painter ─────────────────────────────────────────────────
class _ClaudeLogo extends CustomPainter {
  final Color color;
  const _ClaudeLogo({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const petalCount = 8;
    final outerR = size.width * 0.48;
    final innerR = size.width * 0.18;
    final petalW = size.width * 0.13;

    for (int i = 0; i < petalCount; i++) {
      final angle = (2 * pi * i) / petalCount - pi / 2;
      final petalCx = cx + (outerR - petalW * 1.2) * cos(angle);
      final petalCy = cy + (outerR - petalW * 1.2) * sin(angle);

      canvas.save();
      canvas.translate(petalCx, petalCy);
      canvas.rotate(angle + pi / 2);

      final path = Path();
      final h = petalW * 2.2;
      final w = petalW * 0.75;

      path.moveTo(0, -h / 2);
      path.cubicTo(w, -h / 2, w, h / 2, 0, h / 2);
      path.cubicTo(-w, h / 2, -w, -h / 2, 0, -h / 2);
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // Center dot
    canvas.drawCircle(Offset(cx, cy), innerR, paint);
  }

  @override
  bool shouldRepaint(_ClaudeLogo old) => old.color != color;
}

// ─── Typing dot ───────────────────────────────────────────────────────────────
class _Dot extends StatefulWidget {
  final Duration delay;
  const _Dot({required this.delay});
  @override State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _a = Tween(begin: 0.0, end: -5.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () { if (mounted) _c.forward(); });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _a, builder: (_, __) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      transform: Matrix4.translationValues(0, _a.value, 0),
      child: Container(width: 7, height: 7,
          decoration: BoxDecoration(color: StaticColors.glowBlue.withValues(alpha: 0.70), shape: BoxShape.circle)),
    ));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
}