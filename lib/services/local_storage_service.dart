import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String _keyUser = 'user';
  static const String _keyTxCache = 'tx_cache';

  // ── USER SESSION ─────────────────────────────────────────────────────────
  static Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, userJson);
  }

  static Future<void> saveUserModel(UserModel user) async {
    await saveUser(jsonEncode(user.toJson()));
  }

  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUser);
  }

  static Future<UserModel?> getUserModel() async {
    final raw = await getUser();
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return UserModel.fromJson(map);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUser);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  // ── DEMO GUEST SESSION ───────────────────────────────────────────────────
  static Future<void> saveDemoUser() async {
    final demoUser = {
      'id': '999',
      'name': 'Demo User',
      'email': 'demo@cashly.app',
      'is_demo': true,
      'photo': null,
    };
    await saveUser(jsonEncode(demoUser));

    // Siapkan demo transactions jika cache masih kosong
    final existing = await getTransactionsCache();
    if (existing.isEmpty) {
      final now = DateTime.now();
      final demoList = [
        TransactionModel(
          id: 'demo-1',
          title: 'Gaji Bulanan',
          amount: 8500000,
          date: now.subtract(const Duration(days: 2)),
          isIncome: true,
          category: 'Income',
        ),
        TransactionModel(
          id: 'demo-2',
          title: 'Belanja Mingguan Supermarket',
          amount: 650000,
          date: now.subtract(const Duration(days: 1)),
          isIncome: false,
          category: 'Belanja',
        ),
        TransactionModel(
          id: 'demo-3',
          title: 'Makan Siang Resto',
          amount: 85000,
          date: now,
          isIncome: false,
          category: 'Makanan',
        ),
        TransactionModel(
          id: 'demo-4',
          title: 'Bensin Kendaraan',
          amount: 150000,
          date: now,
          isIncome: false,
          category: 'Transport',
        ),
        TransactionModel(
          id: 'demo-5',
          title: 'Bonus Project Freelance',
          amount: 1200000,
          date: now.subtract(const Duration(days: 5)),
          isIncome: true,
          category: 'Income',
        ),
      ];
      await saveTransactionsCache(demoList);
    }
  }

  // ── TRANSACTION CACHE (OFFLINE FIRST) ────────────────────────────────────
  static Future<void> saveTransactionsCache(List<TransactionModel> txs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = txs.map((e) => e.toJson()).toList();
      await prefs.setString(_keyTxCache, jsonEncode(jsonList));
    } catch (_) {}
  }

  static Future<List<TransactionModel>> getTransactionsCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyTxCache);
      if (raw == null || raw.isEmpty) return [];
      final List list = jsonDecode(raw);
      return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addTransactionLocal(TransactionModel tx) async {
    final list = await getTransactionsCache();
    list.insert(0, tx);
    await saveTransactionsCache(list);
  }

  static Future<void> updateTransactionLocal(TransactionModel tx) async {
    final list = await getTransactionsCache();
    final idx = list.indexWhere((e) => e.id == tx.id);
    if (idx != -1) {
      list[idx] = tx;
      await saveTransactionsCache(list);
    }
  }

  static Future<void> deleteTransactionLocal(String id) async {
    final list = await getTransactionsCache();
    list.removeWhere((e) => e.id == id);
    await saveTransactionsCache(list);
  }
}