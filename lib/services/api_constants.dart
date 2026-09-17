import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Base host selector based on platform
  static String get defaultHost {
    if (kIsWeb) return 'http://localhost/keuangan_api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2/keuangan_api';
      return 'http://localhost/keuangan_api';
    } catch (_) {
      return 'http://localhost/keuangan_api';
    }
  }

  // Active base URL (defaults to platform-specific localhost)
  static String baseUrl = "$defaultHost/config";

  // Endpoints
  static String get loginUrl          => "$baseUrl/login.php";
  static String get registerUrl       => "$baseUrl/register.php";
  static String get getTxUrl          => "$baseUrl/get_transactions.php";
  static String get addTxUrl          => "$baseUrl/add_transactions.php";
  static String get updateTxUrl       => "$baseUrl/update_transactions.php";
  static String get deleteTxUrl       => "$baseUrl/delete_transactions.php";
  static String get updateProfileUrl  => "$baseUrl/update_profile.php";
  static String get updatePasswordUrl => "$baseUrl/update_password.php";
  static String get forgotPasswordUrl => "$baseUrl/forgot_password.php";

  // Helper to format avatar image URL
  static String? resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$defaultHost/$cleanPath";
  }
}
