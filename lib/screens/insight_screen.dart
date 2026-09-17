import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/financial_analytics_service.dart';
import '../theme/app_colors.dart';

class _CatStyle { final Color bg,fg,bar; final IconData icon; const _CatStyle(this.bg,this.fg,this.bar,this.icon); }
const _catMap = <String,_CatStyle>{
  'Makanan'   :_CatStyle(Color(0xFFFFF3E0),Color(0xFFE65100),Color(0xFFFB923C),Icons.restaurant_rounded),
  'Transport' :_CatStyle(Color(0xFFE3F2FD),Color(0xFF1565C0),Color(0xFF3B82F6),Icons.directions_car_rounded),
  'Hiburan'   :_CatStyle(Color(0xFFF3E5F5),Color(0xFF6A1B9A),Color(0xFFA855F7),Icons.movie_rounded),
  'Belanja'   :_CatStyle(Color(0xFFFCE4EC),Color(0xFFC62828),Color(0xFFEF4444),Icons.shopping_bag_rounded),
  'Kesehatan' :_CatStyle(Color(0xFFE8F5E9),Color(0xFF2E7D32),Color(0xFF22C55E),Icons.favorite_rounded),
  'Pendidikan':_CatStyle(Color(0xFFEDE7F6),Color(0xFF4527A0),Color(0xFF8B5CF6),Icons.school_rounded),
  'Rumah'     :_CatStyle(Color(0xFFE0F7FA),Color(0xFF006064),Color(0xFF06B6D4),Icons.home_rounded),
};
_CatStyle _catOf(String cat)=>_catMap[cat]??const _CatStyle(Color(0xFFF1F5F9),Color(0xFF475569),Color(0xFF94A3B8),Icons.label_rounded);

class InsightScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Future<void> Function()? onRefresh;

  const InsightScreen({
    super.key,
    required this.transactions,
    this.onRefresh,
  });

  String _rp(double v)=>NumberFormat.currency(locale:'id_ID',symbol:'Rp ',decimalDigits:0).format(v);
  double get _income =>transactions.where((t)=>t.isIncome).fold(0,(s,t)=>s+t.amount);
  double get _expense=>transactions.where((t)=>!t.isIncome).fold(0,(s,t)=>s+t.amount);

  Map<String,double> get _catSummary {
    final map=<String,double>{};
    for (final tx in transactions) {
      if (!tx.isIncome) {
        final k = tx.category.isNotEmpty ? tx.category : "Lainnya";
        map[k] = (map[k] ?? 0) + tx.amount;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final c=context.colors;
    final sorted=_catSummary.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    final ratio=_income>0?((_income-_expense)/_income*100).clamp(-999,100):0.0;
    final topCat=sorted.isNotEmpty?sorted.first.key:null;
    final topAmt=sorted.isNotEmpty?sorted.first.value:0.0;
    final bottom=MediaQuery.of(context).padding.bottom;
    final score = FinancialAnalyticsService.calculateScore(transactions);

    return Scaffold(
      backgroundColor:c.bgPage,
      body:RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        color: StaticColors.headerBright,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers:[
            SliverToBoxAdapter(child:_buildHeader()),
            SliverPadding(
              padding:EdgeInsets.fromLTRB(20,24,20,bottom+16),
              sliver:SliverList(delegate:SliverChildListDelegate([

                // 🔥 Financial Score Card
                _buildScoreCard(context, score),
                const SizedBox(height:20),

                // 🔥 Aturan Finansial 50/30/20
                _buildRule503020Card(context),
                const SizedBox(height:20),

                _buildBalanceCard(context),
                const SizedBox(height:20),
                _buildKpiRow(context,topCat,topAmt,ratio.toDouble()),
            const SizedBox(height:28),
            _sectionTitle(context,"Pengeluaran per Kategori"),
            const SizedBox(height:14),
            if (sorted.isEmpty) _buildEmpty(context)
            else ...sorted.map((e)=>Padding(padding:const EdgeInsets.only(bottom:12),
                child:_catCard(context,e.key,e.value,_expense))),
          ])),
        ),
      ]),
    ),
  );
}

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
    decoration:const BoxDecoration(gradient:LinearGradient(
      begin:Alignment.topLeft,end:Alignment.bottomRight,
      colors:[StaticColors.headerDeep,StaticColors.headerNavy,StaticColors.headerBlue],stops:[0.0,0.45,1.0],
    )),
    child:Stack(clipBehavior:Clip.none,children:[
      Positioned(top:-30,right:-15,child:_glow(130,StaticColors.headerBright.withValues(alpha: 0.17))),
      Positioned(bottom:-10,left:-10,child:_glow(90,StaticColors.glowBlue.withValues(alpha: 0.11))),
      SafeArea(bottom:false,child:Padding(
        padding:const EdgeInsets.fromLTRB(24,20,24,28),
        child:Row(children:[
          Container(width:40,height:40,
            decoration:BoxDecoration(color:Colors.white.withValues(alpha: 0.12),borderRadius:BorderRadius.circular(12),
                border:Border.all(color:Colors.white.withValues(alpha: 0.15))),
            child:const Icon(Icons.insights_rounded,color:StaticColors.white,size:20),
          ),
          const SizedBox(width:14),
          const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text("Insight Keuangan",style:TextStyle(color:StaticColors.white,fontSize:18,fontWeight:FontWeight.w800,letterSpacing:0.2)),
            SizedBox(height:2),
            Text("Analisis pengeluaran kamu",style:TextStyle(color:StaticColors.white70,fontSize:12)),
          ]),
        ]),
      )),
    ]),
  );

  Widget _glow(double s,Color c)=>Container(width:s,height:s,decoration:BoxDecoration(shape:BoxShape.circle,color:c));

  // ── 🔥 Financial Score Card ───────────────────────────────────────────────
  Widget _buildScoreCard(BuildContext context, FinancialScore score) {
    final c = context.colors;

    // Warna berdasarkan grade
    final Color scoreColor = score.total >= 85 ? StaticColors.incomeGreen
        : score.total >= 70 ? const Color(0xFF3B82F6)
        : score.total >= 55 ? const Color(0xFFF59E0B)
        : score.total >= 40 ? const Color(0xFFF97316)
        : StaticColors.expenseRed;

    final Color scoreBg = score.total >= 85 ? StaticColors.incomeLight
        : score.total >= 70 ? const Color(0xFFEFF6FF)
        : score.total >= 55 ? const Color(0xFFFFFBEB)
        : score.total >= 40 ? const Color(0xFFFFF3E0)
        : StaticColors.expenseLight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(
            color: const Color(0xFF1540A8).withValues(alpha: 0.07),
            blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(width: 3, height: 16,
                decoration: BoxDecoration(color: scoreColor,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text("Financial Score",
                style: TextStyle(color: c.textPrimary, fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: scoreBg,
                borderRadius: BorderRadius.circular(99)),
            child: Text(score.label,
                style: TextStyle(color: scoreColor, fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 20),

        // Score ring + breakdown
        Row(children: [
          // Ring
          SizedBox(
            width: 100, height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _ScoreRingPainter(
                  score: score.total / 100,
                  color: scoreColor,
                  bgColor: scoreBg,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text("${score.total}",
                    style: TextStyle(color: scoreColor, fontSize: 28,
                        fontWeight: FontWeight.w900, letterSpacing: -1)),
                Text("/ 100", style: TextStyle(color: c.textMuted,
                    fontSize: 11, fontWeight: FontWeight.w500)),
              ]),
            ]),
          ),
          const SizedBox(width: 20),

          // Breakdown
          Expanded(child: Column(children: [
            _scoreLine(context, "Tabungan",    score.savingsScore,     30, StaticColors.incomeGreen),
            const SizedBox(height: 10),
            _scoreLine(context, "Konsistensi", score.consistencyScore, 25, const Color(0xFF3B82F6)),
            const SizedBox(height: 10),
            _scoreLine(context, "Tren",        score.trendScore,       25, const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _scoreLine(context, "Diversitas",  score.diversityScore,   20, const Color(0xFFA855F7)),
          ])),
        ]),
        const SizedBox(height: 16),

        // Advice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scoreBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Icon(Icons.lightbulb_outline_rounded, color: scoreColor, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(score.advice,
                style: TextStyle(color: scoreColor, fontSize: 12,
                    fontWeight: FontWeight.w500, height: 1.4))),
          ]),
        ),
      ]),
    );
  }

  Widget _scoreLine(BuildContext context, String label, int value, int max, Color color) {
    final c    = context.colors;
    final pct  = value / max;
    return Row(children: [
      SizedBox(width: 72,
          child: Text(label, style: TextStyle(color: c.textMuted,
              fontSize: 10, fontWeight: FontWeight.w500))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
        ),
      )),
      const SizedBox(width: 6),
      Text("$value",
          style: TextStyle(color: c.textSecondary, fontSize: 10,
              fontWeight: FontWeight.w700)),
    ]);
  }

  // ── 50/30/20 Rule Card ──────────────────────────────────────────────────
  Widget _buildRule503020Card(BuildContext context) {
    final c = context.colors;
    final totalIncome = _income > 0 ? _income : (_expense > 0 ? _expense : 1.0);

    // Kebutuhan (Needs) 50%
    const needsCats = {'Makanan', 'Transport', 'Rumah', 'Kesehatan', 'Pendidikan'};
    final needsSpent = transactions
        .where((t) => !t.isIncome && needsCats.contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);

    // Keinginan (Wants) 30%
    const wantsCats = {'Hiburan', 'Belanja', 'Lainnya'};
    final wantsSpent = transactions
        .where((t) => !t.isIncome && wantsCats.contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);

    // Tabungan (Savings) 20%
    final savings = (_income - _expense).clamp(0.0, double.infinity);

    final needsPct = (needsSpent / totalIncome).clamp(0.0, 1.0);
    final wantsPct = (wantsSpent / totalIncome).clamp(0.0, 1.0);
    final savingsPct = (savings / totalIncome).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1540A8).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3, height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Alokasi Budget 50/30/20",
                    style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Fintech Rule",
                  style: TextStyle(color: Color(0xFF7C3AED), fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ruleRow(c, "Kebutuhan (Target 50%)", needsSpent, needsPct, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
          const SizedBox(height: 12),
          _ruleRow(c, "Keinginan (Target 30%)", wantsSpent, wantsPct, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
          const SizedBox(height: 12),
          _ruleRow(c, "Tabungan (Target 20%)", savings, savingsPct, StaticColors.incomeGreen, StaticColors.incomeLight),
        ],
      ),
    );
  }

  Widget _ruleRow(DynamicColors c, String label, double amount, double pct, Color color, Color bg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(
              "${_rp(amount)} (${(pct * 100).toStringAsFixed(0)}%)",
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            color: color,
            backgroundColor: bg,
          ),
        ),
      ],
    );
  }

  // ── Balance card ──────────────────────────────────────────────────────────
  Widget _buildBalanceCard(BuildContext context) {
    final isPos=_income-_expense>=0;
    return Container(
      padding:const EdgeInsets.all(20),
      decoration:BoxDecoration(
        gradient:const LinearGradient(colors:[StaticColors.headerNavy,StaticColors.headerBlue]),
        borderRadius:BorderRadius.circular(20),
        boxShadow:[BoxShadow(color:StaticColors.headerBlue.withValues(alpha: 0.30),blurRadius:24,offset:const Offset(0,8))],
      ),
      child:Column(children:[
        Row(children:[
          Expanded(child:_balRow("Pemasukan",_income,true)),
          Container(width:1,height:40,color:Colors.white.withValues(alpha: 0.15)),
          Expanded(child:_balRow("Pengeluaran",_expense,false)),
        ]),
        Padding(padding:const EdgeInsets.symmetric(vertical:16),
            child:Divider(color:Colors.white.withValues(alpha: 0.12),thickness:1)),
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          const Text("Saldo Bersih",style:TextStyle(color:StaticColors.white70,fontSize:13,fontWeight:FontWeight.w500)),
          Text(_rp(_income-_expense),style:TextStyle(
              color:isPos?StaticColors.incomeGreen:StaticColors.expenseRed,
              fontSize:18,fontWeight:FontWeight.w800)),
        ]),
      ]),
    );
  }

  Widget _balRow(String label,double val,bool isIncome) {
    final color=isIncome?StaticColors.incomeGreen:StaticColors.expenseRed;
    final bg=isIncome?StaticColors.incomeGreen.withValues(alpha: 0.15):StaticColors.expenseRed.withValues(alpha: 0.15);
    final icon=isIncome?Icons.arrow_downward_rounded:Icons.arrow_upward_rounded;
    return Expanded(child:Column(children:[
      Container(width:32,height:32,decoration:BoxDecoration(color:bg,shape:BoxShape.circle),child:Icon(icon,color:color,size:16)),
      const SizedBox(height:8),
      Text(label,style:const TextStyle(color:StaticColors.white70,fontSize:11,letterSpacing:0.3)),
      const SizedBox(height:4),
      Text(_rp(val),style:const TextStyle(color:StaticColors.white,fontSize:13,fontWeight:FontWeight.w700),overflow:TextOverflow.ellipsis),
    ]));
  }

  // ── KPI row ───────────────────────────────────────────────────────────────
  Widget _buildKpiRow(BuildContext context,String? topCat,double topAmt,double savePct) {
    final c=context.colors;
    final catSt=topCat!=null?_catOf(topCat):null;
    return Row(children:[
      Expanded(child:_kpiCard(context,"Terbesar",topCat??"-",topCat!=null?_rp(topAmt):"Belum ada",
          catSt?.icon??Icons.label_rounded, catSt?.bg??c.bgCard, catSt?.fg??c.textMuted)),
      const SizedBox(width:12),
      Expanded(child:_kpiCard(context,"Rasio Tabungan","${savePct.toStringAsFixed(1)}%",
          savePct>=0?"dari pemasukan":"defisit",
          savePct>=0?Icons.savings_rounded:Icons.warning_amber_rounded,
          savePct>=0?StaticColors.incomeLight:StaticColors.expenseLight,
          savePct>=0?StaticColors.incomeDeep:StaticColors.expenseDeep)),
    ]);
  }

  Widget _kpiCard(BuildContext context,String title,String value,String sub,IconData icon,Color iconBg,Color iconFg) {
    final c=context.colors;
    return Container(
      padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(color:c.bgCard,borderRadius:BorderRadius.circular(18),
        border:Border.all(color:c.cardBorder),
        boxShadow:[BoxShadow(color:const Color(0xFF1540A8).withValues(alpha: 0.07),blurRadius:18,offset:const Offset(0,6))],
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Container(width:34,height:34,decoration:BoxDecoration(color:iconBg,borderRadius:BorderRadius.circular(10)),
              child:Icon(icon,color:iconFg,size:18)),
          const Spacer(),
          Text(title,style:TextStyle(color:c.textMuted,fontSize:10,fontWeight:FontWeight.w600,letterSpacing:0.4)),
        ]),
        const SizedBox(height:12),
        Text(value,style:TextStyle(color:c.textPrimary,fontSize:16,fontWeight:FontWeight.w800),maxLines:1,overflow:TextOverflow.ellipsis),
        const SizedBox(height:2),
        Text(sub,style:TextStyle(color:c.textMuted,fontSize:11)),
      ]),
    );
  }

  Widget _sectionTitle(BuildContext context,String title) {
    final c=context.colors;
    return Row(children:[
      Container(width:4,height:18,decoration:BoxDecoration(color:StaticColors.headerBright,borderRadius:BorderRadius.circular(2))),
      const SizedBox(width:10),
      Text(title,style:TextStyle(color:c.textPrimary,fontSize:15,fontWeight:FontWeight.w700)),
    ]);
  }

  Widget _catCard(BuildContext context,String category,double amount,double total) {
    final c=context.colors;
    final pct=total>0?(amount/total).clamp(0.0,1.0):0.0;
    final style=_catOf(category);
    final label=pct>=0.5?"Tinggi":pct>=0.25?"Sedang":"Rendah";
    final badgeBg=pct>=0.5?StaticColors.expenseLight:pct>=0.25?const Color(0xFFFFF7E6):StaticColors.incomeLight;
    final badgeFg=pct>=0.5?StaticColors.expenseDeep:pct>=0.25?const Color(0xFFB45309):StaticColors.incomeDeep;
    return Container(
      padding:const EdgeInsets.all(16),
      decoration:BoxDecoration(color:c.bgCard,borderRadius:BorderRadius.circular(18),
        border:Border.all(color:c.cardBorder),
        boxShadow:[BoxShadow(color:const Color(0xFF1540A8).withValues(alpha: 0.06),blurRadius:16,offset:const Offset(0,5))],
      ),
      child:Row(children:[
        Container(width:46,height:46,decoration:BoxDecoration(color:style.bg,borderRadius:BorderRadius.circular(13)),
            child:Icon(style.icon,color:style.fg,size:22)),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            Text(category,style:TextStyle(color:c.textPrimary,fontSize:14,fontWeight:FontWeight.w700)),
            Text(_rp(amount),style:TextStyle(color:style.fg,fontSize:13,fontWeight:FontWeight.w700)),
          ]),
          const SizedBox(height:8),
          ClipRRect(borderRadius:BorderRadius.circular(99),
              child:LinearProgressIndicator(value:pct,minHeight:7,color:style.bar,backgroundColor:style.bg)),
          const SizedBox(height:6),
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            Text("${(pct*100).toStringAsFixed(1)}% dari total",style:TextStyle(color:c.textMuted,fontSize:11)),
            Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
              decoration:BoxDecoration(color:badgeBg,borderRadius:BorderRadius.circular(6)),
              child:Text(label,style:TextStyle(color:badgeFg,fontSize:10,fontWeight:FontWeight.w700)),
            ),
          ]),
        ])),
      ]),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final c=context.colors;
    return Container(
      padding:const EdgeInsets.symmetric(vertical:48),
      decoration:BoxDecoration(color:c.bgCard,borderRadius:BorderRadius.circular(18),border:Border.all(color:c.cardBorder)),
      child:Column(children:[
        Icon(Icons.bar_chart_outlined,size:44,color:c.textMuted),
        const SizedBox(height:12),
        Text("Belum ada data pengeluaran",style:TextStyle(color:c.textSecondary,fontSize:14,fontWeight:FontWeight.w600)),
        const SizedBox(height:4),
        Text("Tambahkan transaksi untuk melihat insight",style:TextStyle(color:c.textMuted,fontSize:12)),
      ]),
    );
  }
}

// ─── Score Ring Painter ───────────────────────────────────────────────────────
class _ScoreRingPainter extends CustomPainter {
  final double score;
  final Color  color;
  final Color  bgColor;
  const _ScoreRingPainter({required this.score, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width / 2;
    final cy     = size.height / 2;
    final radius = size.width / 2 - 8;
    const stroke = 10.0;

    // Background ring
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      -pi / 2, 2 * pi, false,
      Paint()..color = bgColor..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round,
    );

    // Score arc
    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        -pi / 2, 2 * pi * score, false,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.score != score || old.color != color;
}