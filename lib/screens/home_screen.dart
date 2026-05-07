import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import 'notification_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  const HomeScreen({super.key, required this.transactions});

  double get _income  => transactions.where((t) =>  t.isIncome).fold(0.0, (s,t) => s+t.amount);
  double get _expense => transactions.where((t) => !t.isIncome).fold(0.0, (s,t) => s+t.amount);

  String _rp(double v) =>
      NumberFormat.currency(locale:'id_ID', symbol:'Rp ', decimalDigits:0).format(v);

  List<TransactionModel> get _recent {
    final l = transactions.reversed.toList();
    return l.length > 5 ? l.sublist(0,5) : l;
  }

  int _notifCount() {
    if (transactions.isEmpty) return 0;
    int c = 0;
    final ratio = _income > 0 ? (_expense/_income)*100 : 0.0;
    if (ratio > 60) c++;
    if (_income - _expense < 0) c++;
    final now = DateTime.now();
    if (transactions.where((t) =>
        t.date.year==now.year && t.date.month==now.month && t.date.day==now.day)
        .isEmpty) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final inc    = _income, exp = _expense, bal = inc - exp;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: c.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, bal, inc, exp)),
          SliverPadding(
            // 🔥 Bottom padding dinamis — ikut MediaQuery yang sudah di-inject MainScreen
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              const SizedBox(height: 24),
              _buildQuickStats(context, inc, exp),
              const SizedBox(height: 24),
              _buildSectionHeader(context, "Transaksi Terkini", "Lihat semua"),
              const SizedBox(height: 12),
              _buildTransactionList(context),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double balance, double income, double expense) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [StaticColors.headerDeep, StaticColors.headerNavy, StaticColors.headerBlue],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(top:-40,right:-30, child:_glow(160,StaticColors.headerBright.withOpacity(0.18))),
        Positioned(top:30,right:50,   child:_glow(80, StaticColors.accentCyan.withOpacity(0.10))),
        Positioned(bottom:-20,left:-20,child:_glow(120,StaticColors.glowBlue.withOpacity(0.12))),
        SafeArea(bottom:false,child:Padding(
          padding: const EdgeInsets.fromLTRB(24,20,24,36),
          child: Column(children:[
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
              Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
                Text(_greeting(), style: const TextStyle(color:StaticColors.white70, fontSize:13, letterSpacing:0.3)),
                const SizedBox(height:2),
                const Text("Dashboard", style:TextStyle(color:StaticColors.white, fontSize:18, fontWeight:FontWeight.w700)),
              ]),
              _notifBtn(context),
            ]),
            const SizedBox(height:32),
            Text("Total Saldo", style:TextStyle(color:StaticColors.glowBlue.withOpacity(0.85), fontSize:13, letterSpacing:1.2, fontWeight:FontWeight.w500)),
            const SizedBox(height:8),
            Text(_rp(balance), style:const TextStyle(color:StaticColors.white, fontSize:34, fontWeight:FontWeight.w800, letterSpacing:-0.5)),
            const SizedBox(height:28),
            Row(children:[
              Expanded(child:_statTile("Pemasukan", income, true)),
              const SizedBox(width:12),
              Expanded(child:_statTile("Pengeluaran", expense, false)),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _glow(double s, Color c) => Container(width:s,height:s, decoration:BoxDecoration(shape:BoxShape.circle,color:c));

  Widget _notifBtn(BuildContext context) {
    final count = _notifCount();
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => NotificationScreen(transactions: transactions))),
      child: Stack(clipBehavior:Clip.none, children:[
        Container(width:42,height:42,
          decoration:BoxDecoration(
            color:Colors.white.withOpacity(0.12),
            borderRadius:BorderRadius.circular(12),
            border:Border.all(color:Colors.white.withOpacity(0.15)),
          ),
          child:const Icon(Icons.notifications_outlined, color:Colors.white, size:20),
        ),
        if (count > 0) Positioned(top:-4,right:-4,
          child:Container(width:18,height:18,
            decoration:const BoxDecoration(color:StaticColors.expenseRed, shape:BoxShape.circle),
            child:Center(child:Text(count>9?"9+":"$count",
                style:const TextStyle(color:Colors.white, fontSize:9, fontWeight:FontWeight.w800))),
          ),
        ),
      ]),
    );
  }

  Widget _statTile(String label, double amount, bool isIncome) {
    final pill      = isIncome ? StaticColors.incomeGreen.withOpacity(0.18) : StaticColors.expenseRed.withOpacity(0.18);
    final iconColor = isIncome ? StaticColors.incomeGreen : StaticColors.expenseRed;
    final icon      = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    return Container(
      padding:const EdgeInsets.symmetric(horizontal:14,vertical:12),
      decoration:BoxDecoration(
        color:Colors.white.withOpacity(0.10), borderRadius:BorderRadius.circular(14),
        border:Border.all(color:Colors.white.withOpacity(0.12)),
      ),
      child:Row(children:[
        Container(width:32,height:32, decoration:BoxDecoration(color:pill,shape:BoxShape.circle),
            child:Icon(icon,color:iconColor,size:16)),
        const SizedBox(width:10),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
          Text(label, style:const TextStyle(color:StaticColors.white70, fontSize:11, letterSpacing:0.3)),
          const SizedBox(height:2),
          Text(_rp(amount), style:const TextStyle(color:StaticColors.white, fontSize:13, fontWeight:FontWeight.w700), overflow:TextOverflow.ellipsis),
        ])),
      ]),
    );
  }

  Widget _buildQuickStats(BuildContext context, double income, double expense) {
    final c = context.colors;
    final total = income + expense;
    final ir = total > 0 ? (income/total).clamp(0.0,1.0) : 0.0;
    final er = total > 0 ? (expense/total).clamp(0.0,1.0) : 0.0;

    return Container(
      padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(
        color:c.bgCard, borderRadius:BorderRadius.circular(20),
        border:Border.all(color:c.cardBorder),
        boxShadow:[BoxShadow(color:const Color(0xFF1540A8).withOpacity(0.07), blurRadius:24, offset:const Offset(0,8))],
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Text("Ringkasan Bulan Ini", style:TextStyle(color:c.textPrimary, fontSize:15, fontWeight:FontWeight.w700)),
        const SizedBox(height:18),
        _progressRow(context,"Pemasukan", ir, _rp(income), StaticColors.incomeGreen, StaticColors.incomeLight, Icons.trending_up_rounded, StaticColors.incomeDeep),
        const SizedBox(height:16),
        _progressRow(context,"Pengeluaran", er, _rp(expense), StaticColors.expenseRed, StaticColors.expenseLight, Icons.trending_down_rounded, StaticColors.expenseDeep),
      ]),
    );
  }

  Widget _progressRow(BuildContext context, String label, double value, String amount,
      Color bar, Color track, IconData icon, Color iconColor) {
    final c = context.colors;
    return Row(children:[
      Container(width:36,height:36,
          decoration:BoxDecoration(color:track, shape:BoxShape.circle),
          child:Icon(icon, color:iconColor, size:18)),
      const SizedBox(width:12),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
          Text(label, style:TextStyle(color:c.textSecondary, fontSize:13, fontWeight:FontWeight.w500)),
          Text(amount, style:TextStyle(color:iconColor, fontSize:13, fontWeight:FontWeight.w700)),
        ]),
        const SizedBox(height:6),
        ClipRRect(borderRadius:BorderRadius.circular(99),
          child:LinearProgressIndicator(value:value, minHeight:7, color:bar, backgroundColor:track)),
      ])),
    ]);
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? action) {
    final c = context.colors;
    return Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
      Text(title, style:TextStyle(color:c.textPrimary, fontSize:15, fontWeight:FontWeight.w700)),
      if (action!=null)
        Text(action, style:const TextStyle(color:StaticColors.headerBright, fontSize:13, fontWeight:FontWeight.w600)),
    ]);
  }

  Widget _buildTransactionList(BuildContext context) {
    final c = context.colors;
    if (_recent.isEmpty) {
      return Container(
        padding:const EdgeInsets.symmetric(vertical:40),
        decoration:BoxDecoration(color:c.bgCard, borderRadius:BorderRadius.circular(20), border:Border.all(color:c.cardBorder)),
        child:Center(child:Column(children:[
          Icon(Icons.receipt_long_outlined, size:40, color:c.textMuted),
          const SizedBox(height:12),
          Text("Belum ada transaksi", style:TextStyle(color:c.textMuted, fontSize:14)),
        ])),
      );
    }
    return Container(
      decoration:BoxDecoration(
        color:c.bgCard, borderRadius:BorderRadius.circular(20),
        border:Border.all(color:c.cardBorder),
        boxShadow:[BoxShadow(color:const Color(0xFF1540A8).withOpacity(0.07), blurRadius:24, offset:const Offset(0,8))],
      ),
      child:Column(children:List.generate(_recent.length, (i) {
        return _txTile(context, _recent[i], i==_recent.length-1);
      })),
    );
  }

  Widget _txTile(BuildContext context, TransactionModel tx, bool isLast) {
    final c = context.colors;
    final isInc = tx.isIncome;
    return Column(children:[
      Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
        child:Row(children:[
          Container(width:44,height:44,
            decoration:BoxDecoration(
              color: isInc ? StaticColors.incomeLight : StaticColors.expenseLight,
              borderRadius:BorderRadius.circular(13)),
            child:Icon(isInc?Icons.arrow_downward_rounded:Icons.arrow_upward_rounded,
              color: isInc?StaticColors.incomeGreen:StaticColors.expenseRed, size:20),
          ),
          const SizedBox(width:14),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text(tx.title, style:TextStyle(color:c.textPrimary, fontSize:14, fontWeight:FontWeight.w600), maxLines:1, overflow:TextOverflow.ellipsis),
            const SizedBox(height:3),
            Text(tx.category??"Lainnya", style:TextStyle(color:c.textMuted, fontSize:12)),
          ])),
          Text("${isInc?'+':'-'} ${_rp(tx.amount)}",
            style:TextStyle(color: isInc?StaticColors.incomeDeep:StaticColors.expenseDeep, fontSize:14, fontWeight:FontWeight.w700)),
        ]),
      ),
      if (!isLast) Divider(height:1, thickness:1, color:c.divider, indent:74),
    ]);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h<11) return "Selamat Pagi ☀️";
    if (h<15) return "Selamat Siang 🌤";
    if (h<18) return "Selamat Sore 🌇";
    return "Selamat Malam 🌙";
  }
}