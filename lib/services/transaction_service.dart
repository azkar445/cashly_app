import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'api_constants.dart';
import 'local_storage_service.dart';

class TransactionService {
  static Future<int> _userId() async {
    final raw = await LocalStorageService.getUser();
    if (raw == null) return 0;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return int.tryParse(map['id']?.toString() ?? '0') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<bool> _isDemo() async {
    final raw = await LocalStorageService.getUser();
    if (raw == null) return false;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map['is_demo'] == true;
    } catch (_) {
      return false;
    }
  }

  // ── LOAD ──────────────────────────────────────────────────────────────────
  static Future<List<TransactionModel>> load() async {
    final cached = await LocalStorageService.getTransactionsCache();

    // Jika mode demo, langsung pakai local cache
    if (await _isDemo()) {
      return cached;
    }

    try {
      final userId = await _userId();
      if (userId > 0) {
        final res = await http.post(
          Uri.parse(ApiConstants.getTxUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId}),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'success') {
            final List list = data['data'] ?? [];
            final remoteList = list.map((e) => TransactionModel.fromJson(e)).toList();
            // Simpan ke cache lokal
            await LocalStorageService.saveTransactionsCache(remoteList);
            return remoteList;
          }
        }
      }
    } catch (_) {
      // Server offline atau error timeout — pakai cache lokal
    }

    return cached;
  }

  // ── ADD ───────────────────────────────────────────────────────────────────
  static Future<bool> add(TransactionModel tx) async {
    // Simpan ke cache lokal seketika
    await LocalStorageService.addTransactionLocal(tx);

    if (await _isDemo()) {
      return true;
    }

    try {
      final userId = await _userId();
      if (userId > 0) {
        final res = await http.post(
          Uri.parse(ApiConstants.addTxUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id"  : userId,
            "title"    : tx.title,
            "amount"   : tx.amount,
            "is_income": tx.isIncome ? 1 : 0,
            "category" : tx.category,
            "date"     : tx.date.toIso8601String(),
          }),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'success' && data['id'] != null) {
            // Update ID di cache jika perlu
            final updatedWithId = TransactionModel(
              id: data['id'].toString(),
              title: tx.title,
              amount: tx.amount,
              date: tx.date,
              isIncome: tx.isIncome,
              category: tx.category,
            );
            await LocalStorageService.updateTransactionLocal(updatedWithId);
          }
          return true;
        }
      }
    } catch (_) {
      // Tetap return true karena sudah tersimpan di cache lokal
    }

    return true;
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  static Future<bool> update(TransactionModel tx) async {
    // Update di cache lokal seketika
    await LocalStorageService.updateTransactionLocal(tx);

    if (await _isDemo()) {
      return true;
    }

    try {
      final userId = await _userId();
      if (userId > 0) {
        final res = await http.post(
          Uri.parse(ApiConstants.updateTxUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id"       : int.tryParse(tx.id) ?? tx.id,
            "user_id"  : userId,
            "title"    : tx.title,
            "amount"   : tx.amount,
            "is_income": tx.isIncome ? 1 : 0,
            "category" : tx.category,
            "date"     : tx.date.toIso8601String(),
          }),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data['status'] == 'success';
        }
      }
    } catch (_) {}

    return true;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  static Future<bool> delete(String id) async {
    // Hapus dari cache lokal seketika
    await LocalStorageService.deleteTransactionLocal(id);

    if (await _isDemo()) {
      return true;
    }

    try {
      final userId = await _userId();
      if (userId > 0) {
        final res = await http.post(
          Uri.parse(ApiConstants.deleteTxUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id"     : int.tryParse(id) ?? id,
            "user_id": userId,
          }),
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data['status'] == 'success';
        }
      }
    } catch (_) {}

    return true;
  }

  static Future<void> clearAll() async {
    await LocalStorageService.saveTransactionsCache([]);
  }
}