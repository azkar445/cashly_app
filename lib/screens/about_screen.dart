import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPage,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(children: [

            // Logo + nama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [StaticColors.headerNavy, StaticColors.headerBlue],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                    color: StaticColors.headerBlue.withOpacity(0.28),
                    blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.monetization_on_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 14),
                RichText(text: const TextSpan(children: [
                  TextSpan(text: "Cash", style: TextStyle(
                      color: Colors.white, fontSize: 32,
                      fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                  TextSpan(text: "ly", style: TextStyle(
                      color: Color(0xFF38BDF8), fontSize: 32,
                      fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                ])),
                const SizedBox(height: 6),
                Text("Kelola keuanganmu dengan cerdas",
                    style: TextStyle(color: Colors.white.withOpacity(0.60),
                        fontSize: 13)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: const Text("Versi 1.0.1",
                      style: TextStyle(color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // Fitur unggulan
            _sectionTitle(context, "Fitur Unggulan"),
            const SizedBox(height: 12),
            _featureGrid(context),
            const SizedBox(height: 28),

            // Info app
            _sectionTitle(context, "Informasi Aplikasi"),
            const SizedBox(height: 12),
            _infoCard(context, [
              _InfoRow(Icons.code_rounded, "Versi App",       "1.0.1 (Build 1)"),
              _InfoRow(Icons.phone_android_rounded, "Platform", "Android"),
              _InfoRow(Icons.storage_rounded, "Database",     "MySQL via PHP API"),
              _InfoRow(Icons.palette_rounded, "Framework",    "Flutter 3.x"),
            ]),
            const SizedBox(height: 28),

            // Developer
            _sectionTitle(context, "Developer"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.bgCard, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.cardBorder),
                boxShadow: [BoxShadow(
                    color: const Color(0xFF1540A8).withOpacity(0.06),
                    blurRadius: 16, offset: const Offset(0, 5))],
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [StaticColors.headerBlue, StaticColors.headerBright],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Dikembangkan oleh",
                        style: TextStyle(color: c.textMuted, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text("Tim Cashly",
                        style: TextStyle(color: c.textPrimary, fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text("Aplikasi manajemen keuangan pribadi",
                        style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 28),

            // Legal
            _sectionTitle(context, "Legal"),
            const SizedBox(height: 12),
            _infoCard(context, [
              _InfoRow(Icons.gavel_rounded,         "Lisensi",          "MIT License"),
              _InfoRow(Icons.privacy_tip_outlined,  "Kebijakan Privasi","Data disimpan lokal & server"),
              _InfoRow(Icons.copyright_rounded,     "Copyright",        "© 2026 Cashly"),
            ]),
            const SizedBox(height: 28),

            // Footer
            Text("Made by MDC Team  ·  2026",
                style: TextStyle(color: c.textMuted.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 4),
            Text("Cashly v1.0.1",
                style: TextStyle(color: c.textMuted.withOpacity(0.4), fontSize: 11)),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [StaticColors.headerDeep, StaticColors.headerNavy, StaticColors.headerBlue],
      stops: [0.0, 0.45, 1.0],
    )),
    child: Stack(clipBehavior: Clip.none, children: [
      Positioned(top: -30, right: -15,
          child: _glow(120, StaticColors.headerBright.withOpacity(0.17))),
      SafeArea(bottom: false, child: Padding(
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
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Tentang Cashly",
                style: TextStyle(color: StaticColors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Text("Informasi aplikasi",
                style: TextStyle(color: StaticColors.white70, fontSize: 11)),
          ]),
        ]),
      )),
    ]),
  );

  Widget _glow(double s, Color c) => Container(
      width: s, height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _sectionTitle(BuildContext context, String title) {
    final c = context.colors;
    return Row(children: [
      Container(width: 3, height: 14,
          decoration: BoxDecoration(color: StaticColors.headerBright,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title.toUpperCase(), style: TextStyle(
          color: c.textSecondary, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    ]);
  }

  Widget _featureGrid(BuildContext context) {
    final features = [
      (Icons.receipt_long_rounded,     const Color(0xFFEFF6FF), StaticColors.headerBright, "Catat Transaksi"),
      (Icons.insights_rounded,         StaticColors.incomeLight, StaticColors.incomeDeep,   "Insight AI"),
      (Icons.smart_toy_rounded,        const Color(0xFFF3E8FF), const Color(0xFF7C3AED),   "AI Asisten"),
      (Icons.workspace_premium_rounded,const Color(0xFFFFF7E6), const Color(0xFFB45309),   "Financial Score"),
      (Icons.dark_mode_rounded,        const Color(0xFF1E1B4B), const Color(0xFF818CF8),   "Dark Mode"),
      (Icons.filter_list_rounded,      StaticColors.incomeLight, StaticColors.incomeDeep,  "Filter & Cari"),
    ];
    final c = context.colors;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: features.map((f) => Container(
        decoration: BoxDecoration(
          color: c.bgCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.cardBorder),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 40, height: 40,
              decoration: BoxDecoration(color: f.$2, borderRadius: BorderRadius.circular(12)),
              child: Icon(f.$1, color: f.$3, size: 20)),
          const SizedBox(height: 8),
          Text(f.$4, textAlign: TextAlign.center,
              style: TextStyle(color: c.textPrimary, fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      )).toList(),
    );
  }

  Widget _infoCard(BuildContext context, List<_InfoRow> rows) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(
            color: const Color(0xFF1540A8).withOpacity(0.06),
            blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(children: List.generate(rows.length, (i) {
        final r = rows[i];
        final isLast = i == rows.length - 1;
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(r.icon, color: StaticColors.headerBright, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(r.label,
                  style: TextStyle(color: c.textSecondary, fontSize: 13))),
              Text(r.value, style: TextStyle(color: c.textPrimary,
                  fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (!isLast) Divider(height: 1, thickness: 1,
              color: c.divider, indent: 64),
        ]);
      })),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}