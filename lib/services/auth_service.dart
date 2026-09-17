import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'local_storage_service.dart';

class AuthService {
  // 🔐 LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (data['status'] == true && data['user'] != null) {
        await LocalStorageService.saveUser(jsonEncode(data['user']));
      }

      return data;
    } catch (e) {
      return {
        "status": false,
        "message": "Gagal terhubung ke server. Pastikan API aktif atau gunakan Mode Demo."
      };
    }
  }

  // 📝 REGISTER
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 5));

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "status": false,
        "message": "Gagal terhubung ke server. Pastikan API aktif."
      };
    }
  }

  // 🌟 GUEST / DEMO LOGIN
  static Future<void> loginAsGuest() async {
    await LocalStorageService.saveDemoUser();
  }
}