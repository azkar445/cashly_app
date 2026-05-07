import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  // 🔹 SIMPAN USER (JSON STRING)
  static Future<void> saveUser(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', userJson);
  }

  // 🔹 AMBIL USER
  static Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user');
  }

  // 🔹 CEK LOGIN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user');
  }

  // 🔹 LOGOUT — hanya hapus sesi, data transaksi ada di server
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}