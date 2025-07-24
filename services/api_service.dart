import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/asha_app/backend_php/api';

  // 🟢 جلب الخدمات العامة للمستخدمين
  static Future<List<dynamic>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/get_services.php'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // 🟢 جلب المزودين حسب فئة معينة
  static Future<List<dynamic>> getProviders(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/get_providers.php?category=$category'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // 💬 جلب التعليقات على خدمة معينة
  static Future<List<dynamic>> getComments(int serviceId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_comments.php?service_id=$serviceId'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // ✅ التحقق من صلاحية التعليق على خدمة
  static Future<bool> checkBooking(int serviceId) async {
    final response = await http.get(Uri.parse('$baseUrl/check_booking.php?service_id=$serviceId'));
    final data = jsonDecode(response.body);
    return data['can_comment'] == true;
  }

  // ➕ إضافة تعليق جديد
  static Future<bool> addComment(int serviceId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_comment.php'),
      body: {
        'service_id': '$serviceId',
        'content': content,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🎯 تقديم طلب انضمام كمزود خدمة
  static Future<bool> joinAsProvider(String name, String phone, String service) async {
    final response = await http.post(
      Uri.parse('$baseUrl/join_as_provider.php'),
      body: {
        'name': name,
        'phone': phone,
        'service': service,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 📝 تحديث ملف المستخدم الشخصي
  static Future<bool> updateUserProfile(int id, String name, String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_user_profile.php'),
      body: {
        'id': '$id',
        'name': name,
        'phone': phone,
        'password': password,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🔐 تغيير كلمة المرور
  static Future<bool> changePassword(int userId, String oldPass, String newPass) async {
    final response = await http.post(
      Uri.parse('$baseUrl/change_password.php'),
      body: {
        'user_id': '$userId',
        'old_password': oldPass,
        'new_password': newPass,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🗑️ حذف الحساب نهائيًا
  static Future<bool> deleteAccount(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_account.php'),
      body: {'user_id': '$userId'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ♻️ طلب استعادة كلمة المرور
  static Future<bool> sendRecovery(String input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot_password.php'),
      body: {'input': input},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🧪 التحقق من الرمز
  static Future<bool> verifyCode(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify_code.php'),
      body: {
        'phone': phone,
        'code': code,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🔑 إعادة تعيين كلمة المرور
  static Future<bool> resetPassword(String phone, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset_password.php'),
      body: {
        'phone': phone,
        'new_password': newPassword,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 📲 إرسال رمز SMS
  static Future<bool> sendSMSCode(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send_sms_code.php'),
      body: {'phone': phone},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🔁 مزامنة رقم الهاتف مع الحساب
  static Future<bool> syncPhone(String userId, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sync_phone.php'),
      body: {
        'user_id': userId,
        'phone': phone,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
}
