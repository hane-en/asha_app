import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String apiBaseUrl = 'http://localhost/backend_php/api/auth';

  // 🔐 تسجيل دخول مستخدم
  static Future<bool> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login.php'),
      body: {'phone': phone, 'password': password},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 📝 تسجيل مستخدم جديد
  static Future<bool> register(
    String name,
    String phone,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/register.php'),
      body: {'name': name, 'phone': phone, 'password': password},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🔐 تسجيل دخول مزود خدمة
  static Future<bool> loginProvider(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login_provider.php'),
      body: {'phone': phone, 'password': password},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 📝 تسجيل مزود خدمة جديد
  static Future<bool> registerProvider(
    String name,
    String phone,
    String password,
    String service,
  ) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/register_provider.php'),
      body: {
        'name': name,
        'phone': phone,
        'password': password,
        'service': service,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
}
