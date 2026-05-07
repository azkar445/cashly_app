class AiService {

  // ── DETECT CATEGORY ──────────────────────────────────────────────────────
  static Future<String> detectCategory(String title) async {
    final t = title.toLowerCase();

    // ── Makanan & Minuman ─────────────────────────────────────────────────
    if (_has(t, [
      'makan','nasi','ayam','soto','sate','bakso','mie','mi ',
      'indomie','rendang','gudeg','gado','lontong','pecel','rawon',
      'pempek','siomay','batagor','ketoprak','bubur',
      'pizza','burger','sandwich','hotdog','sushi','ramen','pasta',
      'steak','salad','kebab','donat','kue','roti','cake','bolu',
      'jajan','snack','cemilan','keripik','coklat','permen','wafer',
      'kopi','coffee','tea','teh','jus','minuman','boba','thai tea',
      'es krim','gelato','milkshake','susu',
      'warung','warteg','kantin','resto','restoran','rumah makan',
      'kafe','cafe','mcdonalds','kfc','mcd','wendy','pizza hut',
      'hokben','solaria','go food','gofood','shopeefood','grabfood',
      'food','lunch','dinner','malam','sarapan','brunch','breakfast',
    ])) {
      return "Makanan";
    }

    // ── Transport ─────────────────────────────────────────────────────────
    if (_has(t, [
      'gojek','grab','ojek','ojol','maxim','indriver',
      'bus','busway','transjakarta','angkot','angkutan',
      'kereta','krl','mrt','lrt','commuter','kai','stasiun',
      'taxi','taksi','bajaj','becak','andong',
      'bensin','bbm','pertalite','pertamax','solar','premium',
      'spbu','pom bensin','pertamina','shell','bp ',
      'tol','parkir','parking','motor','mobil','servis kendaraan',
      'ganti oli','ban ','helm','kendaraan',
      'pesawat','tiket','bandara','airport','penerbangan','lion','garuda',
      'kapal','ferry','pelabuhan','travel','shuttle',
      'transport','transportasi','commute','ongkir',
    ])) {
      return "Transport";
    }

    // ── Hiburan ───────────────────────────────────────────────────────────
    if (_has(t, [
      'netflix','spotify','youtube premium','disney','hbo','vidio',
      'viu','prime video','apple tv','mola','rcti+',
      'game','gaming','top up','topup','diamond','mobile legend',
      'ml ','ff ','pubg','free fire','roblox','steam','playstore',
      'bioskop','cinema','cgv','cineplex','imax','nonton',
      'konser','concert','event','festival','pertunjukan','show',
      'karaoke','bowling','billiard','futsal','gym','fitness',
      'liburan','wisata','piknik','travelling','hotel','resort',
      'villa','airbnb','penginapan','wahana','taman','kebun binatang',
      'museum','pameran','galeri','tiket masuk',
      'hiburan','entertainment','main','rekreasi',
    ])) {
      return "Hiburan";
    }

    // ── Belanja ───────────────────────────────────────────────────────────
    if (_has(t, [
      'shopee','tokopedia','lazada','bukalapak','blibli','tiktok shop',
      'indomaret','alfamart','alfamidi','minimarket','supermarket',
      'hypermart','carrefour','giant','lotte mart','hero ',
      'beli','belanja','shopping','purchase','order','pesan',
      'baju','celana','kaos','kemeja','jaket','dress','rok',
      'sepatu','sandal','tas','dompet','ikat pinggang','topi',
      'pakaian','fashion','outfit','clothing','apparel',
      'handphone','hp ','laptop','komputer','tablet','gadget',
      'elektronik','charger','kabel','earphone','headset','speaker',
      'aksesoris','perabot','furnitur','alat rumah','dapur',
      'deterjen','sabun','sampo','pasta gigi','odol','toiletries',
      'makeup','skincare','kosmetik','lipstik','lotion','serum',
    ])) {
      return "Belanja";
    }

    // ── Kesehatan ─────────────────────────────────────────────────────────
    if (_has(t, [
      'dokter','doctor','dr ','klinik','puskesmas','rumah sakit','rs ',
      'rsia','rsu','rsud','apotek','apotik','farmasi','pharmacy',
      'obat','vitamin','suplemen','paracetamol','ibuprofen','antibiotik',
      'cek darah','lab ','laboratorium','usg','rontgen','mcu',
      'gigi','dental','dokter gigi','cabut gigi','tambal gigi',
      'mata','kacamata','optik','lensa',
      'bpjs','asuransi kesehatan','rawat inap','rawat jalan',
      'psikiater','psikolog','terapi','fisioterapi','pijat','massage',
      'kesehatan','health','medical','medis','imunisasi','vaksin',
    ])) {
      return "Kesehatan";
    }

    // ── Pendidikan ────────────────────────────────────────────────────────
    if (_has(t, [
      'sekolah','kampus','universitas','kuliah','spp','ukt','bpp',
      'les','kursus','bimbel','privat','tutor','workshop','seminar',
      'buku','modul','diktat','materi','alat tulis','atk','stationery',
      'pensil','pulpen','binder','tas sekolah','seragam',
      'udemy','coursera','dicoding','ruangguru','zenius','quipper',
      'edukasi','education','training','pelatihan','sertifikasi',
      'biaya pendidikan','registrasi','pendaftaran mahasiswa',
    ])) {
      return "Pendidikan";
    }

    // ── Rumah & Utilitas ──────────────────────────────────────────────────
    if (_has(t, [
      'listrik','pln','token listrik','tagihan listrik',
      'air','pdam','tagihan air',
      'wifi','internet','indihome','telkom','firstmedia','biznet',
      'sewa','kost','kontrakan','kosan','apartemen','rumah',
      'cicilan','kpr','kredit rumah',
      'gas','elpiji','lpg','tabung gas',
      'tv kabel','main','berlangganan',
      'cat','renovasi','perbaikan','tukang','material bangunan',
      'furniture','perabotan','kasur','sofa','lemari','meja',
      'bayar rumah','iuran','rt ','rw ','sampah','keamanan',
    ])) {
      return "Rumah";
    }

    // ── Income / Pemasukan ────────────────────────────────────────────────
    if (_has(t, [
      'gaji','salary','upah','honor','honorarium',
      'bonus','thr','insentif','komisi','reward',
      'freelance','proyek','project','konsultasi','jasa',
      'transfer masuk','terima','dapat uang','kiriman',
      'hasil','pendapatan','penghasilan','income',
      'dividen','bunga bank','investasi cair','return',
      'cashback','refund','pengembalian','reimburse',
    ])) {
      return "Income";
    }

    return "Lainnya";
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  static bool _has(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  // ── CHATBOT ───────────────────────────────────────────────────────────────
  static Future<String> ask(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));
    final text = prompt.toLowerCase();

    if (_has(text, ['hemat','kurangi','irit'])) {
      return "💡 Tips Hemat:\n\nCoba gunakan metode 50/30/20:\n"
          "• 50% kebutuhan\n• 30% keinginan\n• 20% tabungan\n\n"
          "Kurangi jajan impulsif ya!";
    }
    if (_has(text, ['boros','pengeluaran besar','habis'])) {
      return "⚠️ Analisis:\n\nPengeluaran kamu kemungkinan boros.\n"
          "Coba cek pengeluaran harian dan kurangi yang tidak penting.";
    }
    if (_has(text, ['tabung','nabung','menabung','saving'])) {
      return "💰 Saran Menabung:\n\nSisihkan minimal 10-20% dari pemasukan.\n"
          "Gunakan rekening terpisah biar gak kepake.";
    }
    if (_has(text, ['budget','anggaran','rencana'])) {
      return "📊 Saran Budget:\n\nBuat catatan pengeluaran harian.\n"
          "Kategorikan tiap transaksi agar mudah dievaluasi.";
    }
    if (_has(text, ['investasi','invest','saham','reksa dana'])) {
      return "📈 Saran Investasi:\n\nMulai dari reksa dana pasar uang.\n"
          "Modal kecil bisa mulai dari Rp 10.000!";
    }

    return "🤖 AI Keuangan:\n\nUntuk \"$prompt\"\n\n"
        "Saran: kelola pengeluaran dengan bijak, prioritaskan kebutuhan, dan hindari pembelian impulsif.";
  }

  // ── INSIGHT ───────────────────────────────────────────────────────────────
  static Future<String> generateInsight(List transactions) async {
    double income = 0, expense = 0;
    for (var tx in transactions) {
      if (tx.isIncome) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    if (expense > income)          return "⚠️ Pengeluaran lebih besar dari pemasukan!\nCoba kurangi pengeluaran ya.";
    if (expense > income * 0.7)    return "💡 Pengeluaran cukup tinggi.\nPertimbangkan untuk lebih hemat.";
    if (expense == 0)              return "😎 Belum ada pengeluaran.\nKeuangan aman banget!";
    return "✅ Keuangan masih stabil.\nPertahankan!";
  }
}