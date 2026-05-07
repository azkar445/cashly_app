import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'local_storage_service.dart';

class TransactionService {
  static const String _base = "http://10.0.2.2/keuangan_api/config";

  static Future<int> _userId() async {
    final raw = await LocalStorageService.getUser();
    if (raw == null) return 0;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return int.tryParse(map['id']?.toString() ?? '0') ?? 0;
  }

  // ── LOAD ──────────────────────────────────────────────────────────────────
  static Future<List<TransactionModel>> load() async {
    try {
      final userId = await _userId();
      final res = await http.post(
        Uri.parse("$_base/get_transactions.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId}),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        final List list = data['data'];
        return list.map((e) => TransactionModel.fromJson(e)).toList();
      }
    } catch (e) { print("load error: $e"); }
    return [];
  }

  // ── ADD ───────────────────────────────────────────────────────────────────
  static Future<bool> add(TransactionModel tx) async {
    try {
      final userId = await _userId();
      final res = await http.post(
        Uri.parse("$_base/add_transactions.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id"  : userId,
          "title"    : tx.title,
          "amount"   : tx.amount,
          "is_income": tx.isIncome ? 1 : 0,
          "category" : tx.category,
        }),
      );
      final data = jsonDecode(res.body);
      return data['status'] == 'success';
    } catch (e) { print("add error: $e"); return false; }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  static Future<bool> update(TransactionModel tx) async {
    try {
      final userId = await _userId();
      final res = await http.post(
        Uri.parse("$_base/update_transactions.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id"       : int.tryParse(tx.id) ?? tx.id,
          "user_id"  : userId,
          "title"    : tx.title,
          "amount"   : tx.amount,
          "is_income": tx.isIncome ? 1 : 0,
          "category" : tx.category,
        }),
      );
      final data = jsonDecode(res.body);
      return data['status'] == 'success';
    } catch (e) { print("update error: $e"); return false; }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  static Future<bool> delete(String id) async {
    try {
      final userId = await _userId();
      final res = await http.post(
        Uri.parse("$_base/delete_transactions.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id"     : int.tryParse(id) ?? id,
          "user_id": userId,
        }),
      );
      final data = jsonDecode(res.body);
      return data['status'] == 'success';
    } catch (e) { print("delete error: $e"); return false; }
  }

  static Future<void> clearAll() async {}
}