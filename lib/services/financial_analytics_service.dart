import '../models/transaction.dart';

// ─── Financial Score Result ───────────────────────────────────────────────────
class FinancialScore {
  final int total;           // 0–100
  final int savingsScore;    // 0–30
  final int consistencyScore;// 0–25
  final int trendScore;      // 0–25
  final int diversityScore;  // 0–20
  final String grade;        // A, B, C, D, F
  final String label;        // "Sangat Baik", dll
  final String advice;       // saran utama

  const FinancialScore({
    required this.total,
    required this.savingsScore,
    required this.consistencyScore,
    required this.trendScore,
    required this.diversityScore,
    required this.grade,
    required this.label,
    required this.advice,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────
class FinancialAnalyticsService {

  // ── FINANCIAL SCORE ────────────────────────────────────────────────────────
  static FinancialScore calculateScore(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const FinancialScore(
        total: 0, savingsScore: 0, consistencyScore: 0,
        trendScore: 0, diversityScore: 0,
        grade: 'F', label: 'Belum Ada Data',
        advice: 'Mulai catat transaksi untuk mendapat skor keuanganmu!',
      );
    }

    final income  = transactions.where((t) =>  t.isIncome).fold(0.0, (s,t) => s+t.amount);
    final expense = transactions.where((t) => !t.isIncome).fold(0.0, (s,t) => s+t.amount);
    final ratio   = income > 0 ? (expense / income) : 1.0;

    // 1. Savings Score (0–30)
    // Rasio pengeluaran < 50% → 30, < 70% → 20, < 90% → 10, > 90% → 0
    final int savingsScore = ratio <= 0.50 ? 30
        : ratio <= 0.70 ? 22
        : ratio <= 0.90 ? 12
        : ratio <= 1.0  ? 5
        : 0;

    // 2. Consistency Score (0–25)
    // Berapa banyak hari aktif dalam 30 hari terakhir
    final now   = DateTime.now();
    final last30 = transactions.where((t) =>
        now.difference(t.date).inDays <= 30).toList();
    final activeDays = last30
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day)
            .millisecondsSinceEpoch)
        .toSet().length;
    final int consistencyScore = activeDays >= 20 ? 25
        : activeDays >= 14 ? 20
        : activeDays >= 7  ? 14
        : activeDays >= 3  ? 8
        : activeDays >= 1  ? 4
        : 0;

    // 3. Trend Score (0–25)
    // Bandingkan pengeluaran bulan ini vs bulan lalu
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    final expThisMonth = transactions.where((t) =>
        !t.isIncome &&
        t.date.year == thisMonth.year &&
        t.date.month == thisMonth.month)
        .fold(0.0, (s,t) => s+t.amount);
    final expLastMonth = transactions.where((t) =>
        !t.isIncome &&
        t.date.year == lastMonth.year &&
        t.date.month == lastMonth.month)
        .fold(0.0, (s,t) => s+t.amount);

    int trendScore;
    if (expLastMonth == 0) {
      trendScore = 15; // netral jika tidak ada data bulan lalu
    } else {
      final trendRatio = expThisMonth / expLastMonth;
      trendScore = trendRatio <= 0.80 ? 25  // turun >20% → bagus banget
          : trendRatio <= 0.95 ? 20           // turun sedikit
          : trendRatio <= 1.05 ? 15           // stabil
          : trendRatio <= 1.20 ? 8            // naik sedikit
          : 0;                                 // naik >20% → buruk
    }

    // 4. Diversity Score (0–20)
    // Banyak kategori yang dicatat → lebih sadar keuangan
    final catCount = transactions
        .where((t) => !t.isIncome)
        .map((t) => t.category)
        .toSet().length;
    final int diversityScore = catCount >= 5 ? 20
        : catCount >= 4 ? 16
        : catCount >= 3 ? 12
        : catCount >= 2 ? 8
        : catCount >= 1 ? 4
        : 0;

    final total = (savingsScore + consistencyScore + trendScore + diversityScore)
        .clamp(0, 100);

    String grade, label, advice;
    if (total >= 85) {
      grade = 'A'; label = 'Luar Biasa! 🏆';
      advice = 'Keuanganmu sangat sehat. Pertimbangkan mulai investasi!';
    } else if (total >= 70) {
      grade = 'B'; label = 'Sangat Baik 👍';
      advice = 'Keuangan bagus! Tingkatkan konsistensi pencatatan.';
    } else if (total >= 55) {
      grade = 'C'; label = 'Cukup Baik 📈';
      advice = 'Masih bisa lebih baik. Fokus kurangi pengeluaran tidak perlu.';
    } else if (total >= 40) {
      grade = 'D'; label = 'Perlu Perhatian ⚠️';
      advice = 'Pengeluaran terlalu tinggi. Mulai buat anggaran harian.';
    } else {
      grade = 'F'; label = 'Kritis 🚨';
      advice = 'Segera evaluasi keuangan. Kurangi pengeluaran & tambah pemasukan.';
    }

    return FinancialScore(
      total: total,
      savingsScore: savingsScore,
      consistencyScore: consistencyScore,
      trendScore: trendScore,
      diversityScore: diversityScore,
      grade: grade,
      label: label,
      advice: advice,
    );
  }

}