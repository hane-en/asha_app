import 'dart:convert';
import 'package:http/http.dart' as http;

class ProviderApi {
  static const String baseUrl = 'http://localhost/asha_app/backend_php/api';

  // ✅ جلب خدمات المزود
  static Future<List<dynamic>> getMyServices(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_my_services.php?provider_id=$providerId'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // 🗑️ حذف خدمة
  static Future<bool> deleteMyService(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_my_service.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // ➕ إضافة خدمة جديدة
  static Future<bool> addService(String providerId, String name, String category, String description, String image) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_service.php'),
      body: {
        'name': name,
        'category': category,
        'description': description,
        'image': image,
        'provider_id': providerId,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🔁 تعديل خدمة
  static Future<bool> updateService(int id, String name, String category, String description, String image) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_service.php'),
      body: {
        'id': '$id',
        'name': name,
        'category': category,
        'description': description,
        'image': image,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 📦 جلب إعلانات المزود
  static Future<List<dynamic>> getMyAds(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_my_ads.php?provider_id=$providerId'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // ➕ إضافة إعلان جديد
  static Future<bool> addAd(String providerId, String image, String link) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_ad.php'),
      body: {
        'image': image,
        'link': link,
        'provider_id': providerId,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🔁 تعديل إعلان
  static Future<bool> updateAd(int id, String image, String link) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_ad.php'),
      body: {
        'id': '$id',
        'image': image,
        'link': link,
      },
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 🗑️ حذف إعلان
  static Future<bool> deleteMyAd(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_my_ad.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  // 📅 جلب الحجوزات الخاصة بالمزود
  static Future<List<dynamic>> getMyBookings(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_my_bookings.php?provider_id=$providerId'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // 👥 جلب المستخدمين (للمشرف فقط إن كنت تستخدمه هنا مؤقتًا)
  static Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/get_all_users.php'));
    final data = jsonDecode(response.body);
    return data is List ? data : [];
  }

  // 🗑️ حذف مستخدم
  static Future<bool> deleteUser(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_user.php'),
      body: {'id': '$id'},
    );
    final data = jsonDecode(response.body);
    return data['success'] == true;
  }
}
