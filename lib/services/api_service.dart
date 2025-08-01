import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ApiService {
  static const String baseUrl = Config.apiBaseUrl;

  // Headers للطلبات
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // دالة مساعدة للطلبات
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    String method = 'GET',
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      print('Making request to: $uri'); // Debug info
      print('Method: $method'); // Debug info
      print('Headers: $_headers'); // Debug info

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers);
          break;
        default:
          throw Exception('Method not supported');
      }

      // طباعة معلومات الاستجابة للتشخيص
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // التحقق من نوع المحتوى
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        try {
          final data = jsonDecode(response.body);
          print('Parsed JSON data: $data'); // Debug info

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return data;
          } else {
            throw Exception(data['message'] ?? 'حدث خطأ في الطلب');
          }
        } catch (e) {
          print('JSON Decode Error: $e');
          throw Exception('خطأ في تنسيق البيانات من الخادم');
        }
      } else {
        // إذا لم يكن JSON، قد يكون خطأ في الخادم
        print('Non-JSON Response: ${response.body}');
        throw Exception(
          'الخادم لا يعيد بيانات JSON صحيحة - تأكد من أن الخادم يعمل بشكل صحيح',
        );
      }
    } catch (e) {
      print('Request Error: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception(
          'خطأ في تنسيق البيانات من الخادم - تأكد من أن الخادم يعمل بشكل صحيح',
        );
      }
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ==================== الخدمات ====================

  // جلب جميع الخدمات
  static Future<Map<String, dynamic>> getAllServices({
    int? categoryId,
    int? providerId,
    String? search,
  }) async {
    String endpoint = '/api/services/get_all.php';
    Map<String, String> queryParams = {};

    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (providerId != null) queryParams['provider_id'] = providerId.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    if (queryParams.isNotEmpty) {
      endpoint +=
          '?' +
          queryParams.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&');
    }

    return await _makeRequest(endpoint);
  }

  // جلب الخدمات المميزة
  static Future<Map<String, dynamic>> getFeaturedServices({
    int? categoryId,
    int? limit = 10,
  }) async {
    String endpoint = '/api/services/featured.php';
    Map<String, String> queryParams = {};

    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    if (queryParams.isNotEmpty) {
      endpoint +=
          '?' +
          queryParams.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&');
    }

    return await _makeRequest(endpoint);
  }

  // جلب خدمة محددة
  static Future<Map<String, dynamic>> getServiceById(int serviceId) async {
    return await _makeRequest(
      '/api/services/get_by_id.php?service_id=$serviceId',
    );
  }

  // ==================== الفئات ====================

  // جلب جميع الفئات
  static Future<Map<String, dynamic>> getAllCategories() async {
    print('Calling getAllCategories...'); // Debug info
    try {
      final result = await _makeRequest('/api/categories/get_all.php');
      print('getAllCategories result: $result'); // Debug info
      return result;
    } catch (e) {
      print('Error in getAllCategories: $e'); // Debug info
      // إرجاع بيانات افتراضية في حالة الخطأ
      return {
        'success': false,
        'message': 'خطأ في تحميل الفئات: $e',
        'data': [],
      };
    }
  }

  // جلب فئة محددة
  static Future<Map<String, dynamic>> getCategoryById(int categoryId) async {
    return await _makeRequest(
      '/api/categories/get_by_id.php?category_id=$categoryId',
    );
  }

  // جلب الخدمات حسب الفئة
  static Future<Map<String, dynamic>> getServicesByCategory(
    String categoryName,
  ) async {
    return await _makeRequest(
      '/api/services/get_by_category.php?category_name=${Uri.encodeComponent(categoryName)}',
    );
  }

  // ==================== المزودين ====================

  // جلب مزودي الخدمات حسب الفئة
  static Future<Map<String, dynamic>> getProvidersByCategory(
    int categoryId,
  ) async {
    return await _makeRequest(
      '/api/providers/get_by_category.php?category_id=$categoryId',
    );
  }

  // جلب جميع المزودين مع فلترة متقدمة
  static Future<Map<String, dynamic>> getAllProviders({
    int? categoryId,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? limit,
    int? offset,
  }) async {
    String endpoint = '/api/providers/get_all_providers.php?';
    List<String> params = [];

    if (categoryId != null) {
      params.add('category_id=$categoryId');
    }

    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(search)}');
    }

    if (sortBy != null) {
      params.add('sort_by=$sortBy');
    }

    if (sortOrder != null) {
      params.add('sort_order=$sortOrder');
    }

    if (limit != null) {
      params.add('limit=$limit');
    }

    if (offset != null) {
      params.add('offset=$offset');
    }

    endpoint += params.join('&');

    return await _makeRequest(endpoint);
  }

  // جلب مزودي خدمة معينة
  static Future<Map<String, dynamic>> getServiceProviders(int serviceId) async {
    return await _makeRequest(
      '/api/providers/get_by_service.php?service_id=$serviceId',
    );
  }

  // جلب خدمات مزود معين
  static Future<Map<String, dynamic>> getProviderServices(
    int providerId, {
    int? categoryId,
  }) async {
    String endpoint = '/api/providers/get_services.php?provider_id=$providerId';

    if (categoryId != null) {
      endpoint += '&category_id=$categoryId';
    }

    return await _makeRequest(endpoint);
  }

  // جلب معلومات مزود معين
  static Future<Map<String, dynamic>> getProviderProfile(int providerId) async {
    return await _makeRequest(
      '/api/providers/get_profile.php?provider_id=$providerId',
    );
  }

  // ==================== الحجوزات ====================

  // إنشاء حجز جديد
  static Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int serviceId,
    required String bookingDate,
    required double totalAmount,
    String? notes,
  }) async {
    return await _makeRequest(
      '/api/bookings/create.php',
      method: 'POST',
      body: {
        'user_id': userId,
        'service_id': serviceId,
        'booking_date': bookingDate,
        'total_amount': totalAmount,
        'notes': notes ?? '',
      },
    );
  }

  // ==================== التقييمات ====================

  // إضافة تقييم جديد
  static Future<Map<String, dynamic>> createReview(
    Map<String, dynamic> reviewData,
  ) async {
    return await _makeRequest(
      '/api/reviews/create.php',
      method: 'POST',
      body: reviewData,
    );
  }

  // جلب تفاصيل الخدمة
  static Future<Map<String, dynamic>> getServiceDetails(
    Map<String, dynamic> params,
  ) async {
    String endpoint = '/api/services/get_service_details.php';
    String queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    if (queryString.isNotEmpty) {
      endpoint += '?$queryString';
    }

    return await _makeRequest(endpoint);
  }

  // التحقق من حالة الحجز للمستخدم
  static Future<Map<String, dynamic>> checkUserBookingStatus(
    Map<String, dynamic> params,
  ) async {
    String endpoint = '/api/bookings/check_user_booking_status.php';
    String queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    if (queryString.isNotEmpty) {
      endpoint += '?$queryString';
    }

    return await _makeRequest(endpoint);
  }

  // ==================== المفضلة ====================

  // إضافة/إزالة من المفضلة
  static Future<Map<String, dynamic>> toggleFavorite({
    required int userId,
    required int serviceId,
  }) async {
    return await _makeRequest(
      '/api/favorites/toggle.php',
      method: 'POST',
      body: {'user_id': userId, 'service_id': serviceId},
    );
  }

  // جلب مفضلات المستخدم
  static Future<Map<String, dynamic>> getUserFavorites(int userId) async {
    return await _makeRequest('/api/favorites/get_all.php?user_id=$userId');
  }

  // جلب حجوزات المستخدم
  static Future<Map<String, dynamic>> getUserBookings(
    int userId, {
    String? status,
  }) async {
    Map<String, String> queryParams = {'user_id': userId.toString()};
    if (status != null) {
      queryParams['status'] = status;
    }
    return await _makeRequest(
      '/api/bookings/get_user_bookings.php',
      queryParams: queryParams,
    );
  }

  // ==================== الإعلانات ====================

  // جلب الإعلانات النشطة
  static Future<Map<String, dynamic>> getActiveAds() async {
    return await _makeRequest('/api/ads/get_active_ads.php');
  }

  // ==================== المصادقة ====================

  // تسجيل الدخول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await _makeRequest(
      '/api/auth/login.php',
      method: 'POST',
      body: {'email': email, 'password': password},
    );
  }

  // إنشاء حساب جديد
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    String? phone,
    String? address,
    int? categoryId,
  }) async {
    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'user_type': userType,
    };

    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (categoryId != null) body['category_id'] = categoryId;

    return await _makeRequest(
      '/api/auth/register.php',
      method: 'POST',
      body: body,
    );
  }

  // ==================== فحص الحجوزات ====================

  // فحص ما إذا كان المستخدم قد حجز خدمة معينة وأكملها
  static Future<bool> hasCompletedBooking({
    required int userId,
    required int serviceId,
  }) async {
    try {
      final response = await _makeRequest(
        '/api/bookings/get_user_bookings.php',
        queryParams: {
          'user_id': userId.toString(),
          'service_id': serviceId.toString(),
          'status': 'completed',
        },
      );

      if (response['success'] && response['data'] != null) {
        final bookings = response['data'] as List;
        return bookings.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== فحص المفضلة ====================

  // فحص ما إذا كانت الخدمة في المفضلة
  static Future<bool> isServiceFavorite({
    required int userId,
    required int serviceId,
  }) async {
    try {
      final response = await getUserFavorites(userId);
      if (response['success'] && response['data'] != null) {
        final favorites = response['data'] as List;
        return favorites.any((favorite) => favorite['service_id'] == serviceId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== استعادة كلمة المرور ====================
  static Future<bool> resetPassword(
    String identifier,
    String newPassword,
  ) async {
    // يفترض أن endpoint هو /api/auth/reset_password.php
    final response = await _makeRequest(
      '/api/auth/reset_password.php',
      method: 'POST',
      body: {
        'identifier': identifier, // بريد أو هاتف
        'new_password': newPassword,
      },
    );
    return response['success'] == true;
  }

  // ==================== إرسال رمز SMS ====================
  static Future<bool> sendSMSCode(String phone) async {
    // يفترض أن endpoint هو /api/auth/send_sms_code.php
    final response = await _makeRequest(
      '/api/auth/send_sms_code.php',
      method: 'POST',
      body: {'phone': phone},
    );
    return response['success'] == true;
  }

  // ==================== التحقق من رمز SMS ====================
  static Future<bool> verifyCode(String phone, String code) async {
    // يفترض أن endpoint هو /api/auth/verify_sms_code.php
    final response = await _makeRequest(
      '/api/auth/verify_sms_code.php',
      method: 'POST',
      body: {'phone': phone, 'code': code},
    );
    return response['success'] == true;
  }

  // ==================== إضافة تعليق (تعيد توجيهها إلى createReview) ====================
  static Future<bool> addComment(
    int serviceId,
    String comment,
    double rating,
  ) async {
    // يجب أن يحصل userId من التخزين المحلي أو من السياق
    // هنا نستخدم userId = 1 كمثال
    final userId = 1;
    final reviewData = {
      'user_id': userId,
      'service_id': serviceId,
      'rating': rating.toInt(),
      'comment': comment,
    };
    final response = await createReview(reviewData);
    return response['success'] == true;
  }

  // ==================== جلب بيانات المستخدم ====================
  static Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final response = await _makeRequest(
      '/api/users/get_profile.php?user_id=$userId',
    );
    if (response['success'] == true && response['data'] != null) {
      return response['data'];
    }
    return null;
  }

  // ==================== تحديث الملف الشخصي مع موافقة المشرف ====================
  static Future<Map<String, dynamic>> updateProfileWithApproval(
    int userId,
    Map<String, dynamic> profileData,
  ) async {
    final response = await _makeRequest(
      '/api/users/update_profile_with_approval.php',
      method: 'POST',
      body: {'user_id': userId, ...profileData},
    );
    return response;
  }

  // ==================== تحديث كلمة المرور ====================
  static Future<bool> updatePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _makeRequest(
      '/api/auth/update_password.php',
      method: 'POST',
      body: {
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    return response['success'] == true;
  }

  // ==================== تغيير كلمة المرور ====================
  static Future<Map<String, dynamic>> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _makeRequest(
      '/api/auth/change_password.php',
      method: 'POST',
      body: {
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    return response;
  }

  // ==================== الانضمام كمزود خدمة ====================
  static Future<bool> joinAsProvider(
    String name,
    String phone,
    String service,
  ) async {
    final response = await _makeRequest(
      '/api/provider/join_provider.php',
      method: 'POST',
      body: {'name': name, 'phone': phone, 'service': service},
    );
    return response['success'] == true;
  }
}
