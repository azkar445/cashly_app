import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class _Notif {
  final String title,subtitle,time;
  final IconData icon;
  final Color iconFg,iconBg;
  final bool isWarning;
  const _Notif({required this.title,required this.subtitle,required this.time,required this.icon,required this.iconFg,required this.iconBg,this.isWarning=false});
}

class NotificationScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  const NotificationScreen({super.key,required this.transactions});

  String _rp(double v)=>NumberFormat.currency(locale:'id_ID',symbol:'Rp ',decimalDigits:0).format(v);

  String _timeAgo(DateTime date) {
    final diff=DateTime.now().difference(date);
    if (diff.inMinutes<1) return "Baru saja";
    if (diff.inMinutes<60) return "${diff.inMinutes} menit lalu";
    if (diff.inHours<24) return "${diff.inHours} jam lalu";
    if (diff.inDays<7) return "${diff.inDays} hari lalu";
    return DateFormat('d MMM','id_ID').format(date);
  }

  List<_Notif> _buildNotifs() {
    final result=<_Notif>[];
    if (transactions.isEmpty) return result;
    final now=DateTime.now();
    final income=transactions.where((t)=>t.isIncome).fold(0.0,(s,t)=>s+t.amount);
    final expense=transactions.where((t)=>!t.isIncome).fold(0.0,(s,t)=>s+t.amount);
    final ratio=income>0?(expense/income)*100:0.0;

    final recent=transactions.toList()..sort((a,b)=>b.date.compareTo(a.date));
    for (final tx in recent.take(5)) {
      result.add(_Notif(
        title:tx.isIncome?"Pemasukan Dicatat ✅":"Pengeluaran Dicatat",
        subtitle:"${tx.isIncome?'+':'-'} ${_rp(tx.amount)} · ${tx.title} (${tx.category})",
        time:_timeAgo(tx.date),
        icon:tx.isIncome?Icons.arrow_downward_rounded:Icons.arrow_upward_rounded,
        iconFg:tx.isIncome?StaticColors.incomeDeep:StaticColors.expenseDeep,
        iconBg:tx.isIncome?StaticColors.incomeLight:StaticColors.expenseLight,
      ));
    }

    if (ratio>80) {
      result.insert(0,const _Notif(
      title:"⚠️ Pengeluaran Sangat Tinggi",subtitle:"Rasio pengeluaran melebihi batas aman!",time:"Baru saja",
      icon:Icons.warning_amber_rounded,iconFg:Color(0xFFB45309),iconBg:Color(0xFFFFFBEB),isWarning:true,
    ));
    } else if (ratio>60) result.insert(0,const _Notif(
      title:"Pengeluaran Mulai Tinggi",subtitle:"Coba kurangi pengeluaran tidak perlu.",time:"Baru saja",
      icon:Icons.info_outline_rounded,iconFg:StaticColors.headerBright,iconBg:Color(0xFFEFF6FF),
    ));

    if (income-expense<0) {
      result.insert(0,_Notif(
      title:"🔴 Saldo Minus!",subtitle:"Pengeluaran melebihi pemasukan sebesar ${_rp((expense-income).abs())}.",time:"Baru saja",
      icon:Icons.account_balance_wallet_outlined,iconFg:StaticColors.expenseDeep,iconBg:StaticColors.expenseLight,isWarning:true,
    ));
    }

    final todayTx=transactions.where((t)=>t.date.year==now.year&&t.date.month==now.month&&t.date.day==now.day).toList();
    if (todayTx.isEmpty) {
      result.add(const _Notif(
      title:"📝 Reminder Hari Ini",subtitle:"Belum ada transaksi hari ini. Jangan lupa catat ya!",time:"Hari ini",
      icon:Icons.edit_note_rounded,iconFg:StaticColors.headerBright,iconBg:Color(0xFFEFF6FF),
    ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final c=context.colors;
    final notifs=_buildNotifs();
    final warnings=notifs.where((n)=>n.isWarning).toList();
    final others=notifs.where((n)=>!n.isWarning).toList();

    return Scaffold(
      backgroundColor:c.bgPage,
      body:Column(children:[
        _buildHeader(context,notifs.length),
        Expanded(child:notifs.isEmpty?_buildEmpty(context):ListView(
          padding:const EdgeInsets.fromLTRB(20,20,20,40),
          children:[
            if (warnings.isNotEmpty)...[
              _sectionTitle(context,"Perlu Perhatian",Icons.warning_amber_rounded,const Color(0xFFB45309)),
              const SizedBox(height:10),
              ...warnings.map((n)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_card(context,n))),
              const SizedBox(height:16),
            ],
            if (others.isNotEmpty)...[
              _sectionTitle(context,"Aktivitas Terbaru",Icons.history_rounded,StaticColors.headerBright),
              const SizedBox(height:10),
              ...others.map((n)=>Padding(padding:const EdgeInsets.only(bottom:10),child:_card(context,n))),
            ],
          ],
        )),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context,int count) {
    return Container(
      decoration:const BoxDecoration(gradient:LinearGradient(
        begin:Alignment.topLeft,end:Alignment.bottomRight,
        colors:[StaticColors.headerDeep,StaticColors.headerNavy,StaticColors.headerBlue],stops:[0.0,0.45,1.0],
      )),
      child:Stack(clipBehavior:Clip.none,children:[
        Positioned(top:-30,right:-15,child:_glow(130,StaticColors.headerBright.withOpacity(0.17))),
        SafeArea(bottom:false,child:Padding(
          padding:const EdgeInsets.fromLTRB(20,16,20,24),
          child:Row(children:[
            GestureDetector(onTap:()=>Navigator.pop(context),
              child:Container(width:38,height:38,
                decoration:BoxDecoration(color:Colors.white.withOpacity(0.12),borderRadius:BorderRadius.circular(10),
                    border:Border.all(color:Colors.white.withOpacity(0.15))),
                child:const Icon(Icons.arrow_back_ios_new_rounded,color:StaticColors.white,size:16),
              ),
            ),
            const SizedBox(width:14),
            const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text("Notifikasi",style:TextStyle(color:StaticColors.white,fontSize:18,fontWeight:FontWeight.w800,letterSpacing:0.2)),
              Text("Update aktivitas keuanganmu",style:TextStyle(color:StaticColors.white70,fontSize:11)),
            ])),
            if (count>0) Container(
              padding:const EdgeInsets.symmetric(horizontal:11,vertical:5),
              decoration:BoxDecoration(color:StaticColors.expenseRed,borderRadius:BorderRadius.circular(99),
                  boxShadow:[BoxShadow(color:StaticColors.expenseRed.withOpacity(0.40),blurRadius:8,offset:const Offset(0,2))]),
              child:Text("$count baru",style:const TextStyle(color:StaticColors.white,fontSize:11,fontWeight:FontWeight.w700)),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _glow(double s,Color c)=>Container(width:s,height:s,decoration:BoxDecoration(shape:BoxShape.circle,color:c));

  Widget _sectionTitle(BuildContext context,String title,IconData icon,Color color) {
    final c=context.colors;
    return Row(children:[
      Container(width:3,height:16,decoration:BoxDecoration(color:color,borderRadius:BorderRadius.circular(2))),
      const SizedBox(width:8),
      Icon(icon,size:14,color:color),
      const SizedBox(width:6),
      Text(title,style:TextStyle(color:c.textPrimary,fontSize:13,fontWeight:FontWeight.w700)),
    ]);
  }

  Widget _card(BuildContext context,_Notif n) {
    final c=context.colors;
    return Container(
      padding:const EdgeInsets.all(14),
      decoration:BoxDecoration(color:c.bgCard,borderRadius:BorderRadius.circular(16),
        border:Border.all(color:n.isWarning?const Color(0xFFB45309).withOpacity(0.30):c.cardBorder,
            width:n.isWarning?1.5:1),
        boxShadow:[BoxShadow(color:const Color(0xFF1540A8).withOpacity(0.06),blurRadius:16,offset:const Offset(0,4))],
      ),
      child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Container(width:44,height:44,decoration:BoxDecoration(color:n.iconBg,borderRadius:BorderRadius.circular(12)),
            child:Icon(n.icon,color:n.iconFg,size:21)),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
            Expanded(child:Text(n.title,style:TextStyle(color:c.textPrimary,fontSize:13,fontWeight:FontWeight.w700),maxLines:1,overflow:TextOverflow.ellipsis)),
            const SizedBox(width:8),
            Text(n.time,style:TextStyle(color:c.textMuted,fontSize:10)),
          ]),
          const SizedBox(height:4),
          Text(n.subtitle,style:TextStyle(color:c.textSecondary,fontSize:12,height:1.4)),
        ])),
      ]),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final c=context.colors;
    return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:72,height:72,decoration:BoxDecoration(color:c.bgCard,shape:BoxShape.circle,border:Border.all(color:c.cardBorder)),
          child:Icon(Icons.notifications_none_rounded,size:34,color:c.textMuted)),
      const SizedBox(height:16),
      Text("Belum ada notifikasi",style:TextStyle(color:c.textSecondary,fontSize:15,fontWeight:FontWeight.w600)),
      const SizedBox(height:6),
      Text("Notifikasi muncul otomatis\nsetelah menambahkan transaksi",
          textAlign:TextAlign.center,style:TextStyle(color:c.textMuted,fontSize:12,height:1.5)),
    ]));
  }
}