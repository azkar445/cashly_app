import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_storage_service.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2/keuangan_api/config";

  // 🔐 LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      // 🔥 SIMPAN FULL USER
      await LocalStorageService.saveUser(
        jsonEncode(data['user']),
      );
    }

    return data;
  }

  // 📝 REGISTER
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/register.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }
}