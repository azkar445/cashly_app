import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? _expandedIndex;

  static const _faqs = [
    _FAQ(
      category: "Transaksi",
      icon: Icons.receipt_long_rounded,
      iconBg: Color(0xFFEFF6FF),
      iconFg: StaticColors.headerBright,
      items: [
        _FAQItem(
          q: "Bagaimana cara menambah transaksi?",
          a: "Buka tab Transaksi, lalu tap tombol + di pojok kanan atas header. Isi judul, nominal, pilih tipe (Pemasukan/Pengeluaran), dan kategori. AI akan otomatis mendeteksi kategori dari judul transaksi jika kamu tidak memilih manual.",
        ),
        _FAQItem(
          q: "Bagaimana cara mengedit atau menghapus transaksi?",
          a: "Di tab Transaksi, kamu bisa:\n• Swipe kanan pada transaksi untuk edit\n• Swipe kiri pada transaksi untuk hapus\n• Long press untuk melihat pilihan aksi",
        ),
        _FAQItem(
          q: "Bagaimana cara filter dan mencari transaksi?",
          a: "Tap ikon 🔍 di header tab Transaksi untuk membuka search bar. Kamu juga bisa filter berdasarkan tipe (Semua/Pemasukan/Pengeluaran) dan kategori melalui bar filter di bawah header.",
        ),
        _FAQItem(
          q: "Apakah kategori bisa dideteksi otomatis?",
          a: "Ya! AI Cashly akan mendeteksi kategori berdasarkan judul transaksi. Misalnya 'Nasi ayam' → Makanan, 'Grab' → Transport. Kamu juga bisa pilih kategori manual sebelum menyimpan.",
        ),
      ],
    ),
    _FAQ(
      category: "Akun & Keamanan",
      icon: Icons.shield_outlined,
      iconBg: Color(0xFFDCFCE7),
      iconFg: StaticColors.incomeDeep,
      items: [
        _FAQItem(
          q: "Bagaimana cara mengubah password?",
          a: "Buka tab Profil → Ubah Password. Masukkan password lama, lalu password baru minimal 6 karakter. Ada indikator kekuatan password untuk membantumu membuat password yang aman.",
        ),
        _FAQItem(
          q: "Bagaimana jika lupa password?",
          a: "Di halaman Login, tap 'Lupa password?'. Masukkan email yang terdaftar, lalu ikuti langkah untuk membuat password baru.",
        ),
        _FAQItem(
          q: "Bagaimana cara mengubah foto profil?",
          a: "Buka tab Profil → Edit Profil. Tap pada foto profil atau tombol 'Ubah Foto Profil'. Kamu bisa mengambil foto dari kamera atau memilih dari galeri.",
        ),
        _FAQItem(
          q: "Apakah data saya aman?",
          a: "Data transaksi disimpan di server dengan keamanan password yang di-hash menggunakan BCrypt. Data hanya bisa diakses menggunakan akun kamu.",
        ),
      ],
    ),
    _FAQ(
      category: "Insight & AI",
      icon: Icons.insights_rounded,
      iconBg: Color(0xFFF3E8FF),
      iconFg: Color(0xFF7C3AED),
      items: [
        _FAQItem(
          q: "Apa itu Financial Score?",
          a: "Financial Score adalah skor 0-100 yang menggambarkan kesehatan keuanganmu. Dihitung dari 4 faktor:\n• Tabungan (30 poin) — rasio pengeluaran vs pemasukan\n• Konsistensi (25 poin) — aktif catat transaksi\n• Tren (25 poin) — tren pengeluaran vs bulan lalu\n• Diversitas (20 poin) — variasi kategori yang dicatat",
        ),
        _FAQItem(
          q: "Bagaimana cara mendapat Financial Score tinggi?",
          a: "Beberapa tips:\n• Jaga pengeluaran di bawah 70% pemasukan\n• Catat transaksi setiap hari secara konsisten\n• Kurangi pengeluaran dibanding bulan lalu\n• Catat berbagai kategori pengeluaran",
        ),
        _FAQItem(
          q: "Bagaimana cara menggunakan AI Asisten?",
          a: "Buka tab AI, lalu ketik pertanyaan tentang keuanganmu. Kamu bisa tanya tentang analisis keuangan, tips hemat, saran investasi, atau cek saldo. AI juga menampilkan Financial Score-mu di halaman utama tab AI.",
        ),
      ],
    ),
    _FAQ(
      category: "Tampilan & Lainnya",
      icon: Icons.palette_outlined,
      iconBg: Color(0xFFFFF7E6),
      iconFg: Color(0xFFB45309),
      items: [
        _FAQItem(
          q: "Bagaimana cara mengaktifkan Dark Mode?",
          a: "Buka tab Profil → Preferensi → Tampilan. Tap toggle untuk mengaktifkan/menonaktifkan Dark Mode. Perubahan langsung berlaku ke seluruh tampilan app.",
        ),
        _FAQItem(
          q: "Kenapa data tidak muncul setelah login?",
          a: "Pastikan koneksi internet atau server lokal (XAMPP) aktif. Data diambil dari server setiap kali buka tab. Coba tarik ke bawah untuk refresh atau keluar dan masuk kembali.",
        ),
        _FAQItem(
          q: "Apakah data hilang saat logout?",
          a: "Tidak! Data transaksi tersimpan di server database (MySQL). Saat logout, hanya sesi login yang dihapus. Data akan tetap ada saat kamu login kembali dengan akun yang sama.",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPage,
      body: Column(children: [
        _buildHeader(context),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            // Search hint card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [StaticColors.headerNavy, StaticColors.headerBlue],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.help_outline_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ada pertanyaan?",
                        style: TextStyle(color: Colors.white, fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text("Temukan jawaban di bawah ini",
                        style: TextStyle(color: StaticColors.white70,
                            fontSize: 11)),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 24),

            // FAQ sections
            ..._faqs.asMap().entries.expand((entry) {
              final i   = entry.key;
              final faq = entry.value;
              return [
                _buildCategoryHeader(context, faq),
                const SizedBox(height: 10),
                _buildFAQSection(context, faq, i),
                const SizedBox(height: 20),
              ];
            }),

            // Contact
            _buildContactCard(context),
          ],
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
          child: _glow(120, StaticColors.headerBright.withValues(alpha: 0.17))),
      SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: StaticColors.white, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Bantuan & FAQ",
                style: TextStyle(color: StaticColors.white, fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Text("Pertanyaan yang sering ditanyakan",
                style: TextStyle(color: StaticColors.white70, fontSize: 11)),
          ]),
        ]),
      )),
    ]),
  );

  Widget _glow(double s, Color c) => Container(
      width: s, height: s,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _buildCategoryHeader(BuildContext context, _FAQ faq) {
    final c = context.colors;
    return Row(children: [
      Container(width: 3, height: 16,
          decoration: BoxDecoration(color: faq.iconFg,
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Container(width: 24, height: 24,
          decoration: BoxDecoration(color: faq.iconBg,
              borderRadius: BorderRadius.circular(7)),
          child: Icon(faq.icon, color: faq.iconFg, size: 14)),
      const SizedBox(width: 8),
      Text(faq.category.toUpperCase(), style: TextStyle(
          color: c.textSecondary, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    ]);
  }

  Widget _buildFAQSection(BuildContext context, _FAQ faq, int catIndex) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(
            color: const Color(0xFF1540A8).withValues(alpha: 0.06),
            blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(children: List.generate(faq.items.length, (i) {
        // Global index untuk expanded state
        final globalIdx = catIndex * 100 + i;
        final isExpanded = _expandedIndex == globalIdx;
        final isLast = i == faq.items.length - 1;
        final item = faq.items[i];

        return Column(children: [
          InkWell(
            onTap: () => setState(() =>
                _expandedIndex = isExpanded ? null : globalIdx),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Expanded(child: Text(item.q,
                    style: TextStyle(
                      color: isExpanded
                          ? StaticColors.headerBright
                          : c.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ))),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? StaticColors.headerBright : c.textMuted,
                      size: 20),
                ),
              ]),
            ),
          ),

          // Answer dengan animasi
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: isExpanded
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item.a,
                        style: const TextStyle(
                          color: StaticColors.headerBlue,
                          fontSize: 13, height: 1.6,
                        )),
                  )
                : const SizedBox.shrink(),
          ),

          if (!isLast) Divider(height: 1, thickness: 1,
              color: c.divider, indent: 16),
        ]);
      })),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.bgCard, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 3, height: 14,
              decoration: BoxDecoration(color: StaticColors.headerBright,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text("MASIH ADA PERTANYAAN?", style: TextStyle(
              color: c.textSecondary, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 14),
        Text("Kalau pertanyaanmu belum terjawab di atas, "
            "coba tanyakan ke AI Asisten Cashly — dia siap membantu 24/7!",
            style: TextStyle(color: c.textSecondary, fontSize: 13, height: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(children: [
            Icon(Icons.smart_toy_rounded,
                color: StaticColors.headerBright, size: 20),
            SizedBox(width: 10),
            Text("Buka tab AI untuk bertanya langsung",
                style: TextStyle(color: StaticColors.headerBright,
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────
class _FAQ {
  final String   category;
  final IconData icon;
  final Color    iconBg;
  final Color    iconFg;
  final List<_FAQItem> items;
  const _FAQ({
    required this.category, required this.icon,
    required this.iconBg,   required this.iconFg,
    required this.items,
  });
}

class _FAQItem {
  final String q;
  final String a;
  const _FAQItem({required this.q, required this.a});
}