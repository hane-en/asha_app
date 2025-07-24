import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApi {
  static const String baseUrl = 'http://localhost/asha_app/backend_php/api';

  // ✅ تسجيل دخول المشرف
  static Future<bool> loginAdmin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login_admin.php'),
      body: {'username': username, 'password': password},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ جلب جميع الخدمات
  static Future<List<dynamic>> getAllServices() async {
    final response = await http.get(Uri.parse('$baseUrl/get_all_services.php'));
    final data = jsonDecode(response.body);
    return data['success'] == true ? data['data'] : [];
  }

  // ✅ حذف خدمة
  static Future<bool> deleteService(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_service.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ جلب التعليقات
  static Future<List<dynamic>> getAllComments() async {
    final response = await http.get(Uri.parse('$baseUrl/get_all_comments.php'));
    final data = jsonDecode(response.body);
    return data['success'] == true ? data['data'] : [];
  }

  // ✅ حذف تعليق
  static Future<bool> deleteComment(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_comment.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ جلب الحجوزات
  static Future<List<dynamic>> getAllBookings() async {
    final response = await http.get(Uri.parse('$baseUrl/get_all_bookings.php'));
    final data = jsonDecode(response.body);
    return data['success'] == true ? data['data'] : [];
  }

  // ✅ جلب جميع الإعلانات
  static Future<List<dynamic>> getAllAds() async {
    final response = await http.get(Uri.parse('$baseUrl/get_all_ads.php'));
    final data = jsonDecode(response.body);
    return data['success'] == true ? data['data'] : [];
  }

  // ✅ حذف إعلان
  static Future<bool> deleteAd(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_ad.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ جلب طلبات الانضمام
  static Future<List<dynamic>> getJoinRequests() async {
    final response = await http.get(Uri.parse('$baseUrl/get_join_requests.php'));
    final data = jsonDecode(response.body);
    return data;
  }

  // ✅ قبول طلب انضمام مزود خدمة
  static Future<bool> approveProvider(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/approve_provider.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
}
