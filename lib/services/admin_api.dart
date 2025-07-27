import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApi {
  static const String baseUrl = 'http://192.168.149.247/asha_app_backend';

  // ✅ تسجيل دخول المشرف
  static Future<bool> loginAdmin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/admin_login.php'),
      body: {'username': username, 'password': password},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ جلب جميع الخدمات
  static Future<List<dynamic>> getAllServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/get_all_services.php'),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true ? data['data'] : [];
  }

  // ✅ حذف خدمة
  static Future<bool> deleteService(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/delete_service.php'),
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

  // ✅ جلب جميع الحجوزات مع الإحصائيات
  static Future<Map<String, dynamic>> getAllBookingsWithStats({
    String? status,
  }) async {
    String url = '$baseUrl/admin/get_all_bookings.php';
    if (status != null && status != 'الكل') {
      url += '?status=$status';
    }

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    return data['success'] == true
        ? data
        : {'success': false, 'data': [], 'stats': {}};
  }

  // ✅ جلب جميع الإعلانات مع الإحصائيات
  static Future<Map<String, dynamic>> getAllAdsWithStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/get_all_ads.php'),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true
        ? data
        : {'success': false, 'data': [], 'stats': {}};
  }

  // ✅ حذف إعلان مع إشعار المزود
  static Future<Map<String, dynamic>> deleteAdWithNotification(
    int adId,
    String reason,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/delete_ad.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ad_id': adId, 'reason': reason}),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  // ✅ تحديث حالة الحجز
  static Future<bool> updateBookingStatus(
    int bookingId,
    String newStatus,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/update_booking_status.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'booking_id': bookingId, 'status': newStatus}),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ حذف حجز
  static Future<bool> deleteBooking(int bookingId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/delete_booking.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'booking_id': bookingId}),
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ✅ جلب طلبات الانضمام
  static Future<List<dynamic>> getJoinRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/get_provider_requests.php'),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  // ✅ قبول طلب انضمام مزود خدمة
  static Future<bool> approveProvider(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/manage_provider_requests.php'),
      body: {'id': '$id', 'action': 'approve'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
}
