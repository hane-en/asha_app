import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ApiService {
  static const String baseUrl = Config.apiBaseUrl;

<<<<<<< HEAD
  // Helper method to make API requests with optional message suppression
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    String? body,
    bool isPost = false,
    bool suppressMessages = false,
  }) async {
    try {
      final url = '$_baseUrl/$endpoint';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'EventServicesApp/${Config.appVersion}',
      };

      if (Config.enableLogging) {
        print('API Request: ${isPost ? 'POST' : 'GET'} $url');
        if (body != null) {
          print('Request Body: $body');
        }
      }

      http.Response response;
      if (isPost) {
        response = await http
            .post(Uri.parse(url), headers: headers, body: body)
            .timeout(_timeout);
      } else {
        response = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(_timeout);
=======
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
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
      }

      // طباعة معلومات الاستجابة للتشخيص
      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      // التحقق من نوع المحتوى
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        try {
<<<<<<< HEAD
          final responseData = json.decode(response.body);

          // إخفاء رسائل النجاح إذا كان مطلوباً
          if (!suppressMessages && responseData['success'] == true) {
            print('✅ API Success: ${responseData['message'] ?? 'No message'}');
          }

          return responseData;
=======
          final data = jsonDecode(response.body);
          print('Parsed JSON data: $data'); // Debug info

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return data;
          } else {
            throw Exception(data['message'] ?? 'حدث خطأ في الطلب');
          }
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
        } catch (e) {
          print('JSON Decode Error: $e');
          throw Exception('خطأ في تنسيق البيانات من الخادم');
        }
      } else {
<<<<<<< HEAD
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        return {
          'success': false,
          'message': 'خطأ في الاتصال بالخادم (${response.statusCode})',
        };
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      return {'success': false, 'message': Config.networkErrorMessage};
    } on TimeoutException catch (e) {
      print('Timeout Exception: $e');
      return {'success': false, 'message': Config.timeoutErrorMessage};
    } on FormatException catch (e) {
      print('Format Exception: $e');
      return {'success': false, 'message': 'خطأ في تنسيق البيانات'};
    } catch (e) {
      if (Config.enableLogging) {
        print('API Error: $e');
      }
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // Favorites methods
  static Future<bool> addToFavorites(int userId, int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/favorites/toggle_simple.php',
        body: json.encode({'user_id': userId, 'service_id': serviceId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  static Future<bool> removeFavorite(int userId, int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/favorites/toggle_simple.php',
        body: json.encode({'user_id': userId, 'service_id': serviceId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  static Future<bool> removeFromFavorites(int userId, int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/favorites/remove.php',
        body: json.encode({'user_id': userId, 'service_id': serviceId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites(int userId) async {
    try {
      final data = await _makeRequest(
        'api/favorites/get_user_favorites_simple.php?user_id=$userId',
      );
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Get providers by category
  static Future<List<Map<String, dynamic>>> getProvidersByCategory(
    int categoryId,
  ) async {
    try {
      final data = await _makeRequest(
        'api/providers/get_by_category.php?category_id=$categoryId',
      );
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting providers by category: $e');
      return [];
    }
  }

  // Get services by provider
  static Future<List<Service>> getServicesByProvider(int providerId) async {
    try {
      final data = await _makeRequest(
        'api/services/get_by_provider.php?provider_id=$providerId',
      );
      if (data['success'] == true && data['data'] != null) {
        final servicesData = data['data']['services'] ?? data['data'];
        if (servicesData is List) {
          return List<Service>.from(
            servicesData.map((item) => Service.fromJson(item)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error getting services by provider: $e');
      return [];
    }
  }

  // Create new booking
  static Future<bool> createNewBooking(Map<String, dynamic> bookingData) async {
    try {
      final data = await _makeRequest(
        'api/bookings/create.php',
        body: json.encode(bookingData),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  // Get all ads
  static Future<List<AdModel>> getAllAds() async {
    try {
      final data = await _makeRequest('api/ads/get_all.php');
      if (data['success'] == true && data['data'] != null) {
        final adsData = data['data']['ads'] ?? data['data'];
        if (adsData is List) {
          return List<AdModel>.from(
            adsData.map((item) => AdModel.fromJson(item)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error getting ads: $e');
      return [];
    }
  }

  // Services methods
  static Future<List<Service>> getServicesByCategory(String category) async {
    try {
      final data = await _makeRequest(
        'api/services/get_all.php?category_id=$category',
      );
      if (data['success'] == true && data['data'] != null) {
        final servicesData = data['data']['services'] ?? data['data'];
        if (servicesData is List) {
          return List<Service>.from(
            servicesData.map((item) => Service.fromJson(item)),
          );
        }
      }
      return [];
    } catch (e) {
      print('Error getting services by category: $e');
      return [];
    }
  }

  // Get services by category ID
  static Future<List<Service>> getServicesByCategoryId(int categoryId) async {
    try {
      print('🔍 Fetching services for category ID: $categoryId');
      final data = await _makeRequest(
        'api/services/get_all.php?category_id=$categoryId',
      );
      print('📊 API response for category $categoryId: $data');

      if (data['success'] == true && data['data'] != null) {
        final servicesData = data['data']['services'] ?? data['data'];
        print('📋 Services data for category $categoryId: $servicesData');

        if (servicesData is List) {
          final result = List<Service>.from(
            servicesData.map((item) => Service.fromJson(item)),
          );
          print(
            '✅ Processed services for category $categoryId: ${result.length} services',
          );
          return result;
        } else {
          print(
            '⚠️ Services data is not a List for category $categoryId: ${servicesData.runtimeType}',
          );
        }
      } else {
        print(
          '❌ API returned success: false for category $categoryId - ${data['message']}',
        );
      }
      return [];
    } catch (e) {
      print('❌ Error getting services by category ID $categoryId: $e');
      return [];
    }
  }

  static Future<List<Service>> getAllServices() async {
    try {
      print('🔍 Fetching all services...');
      final data = await _makeRequest('api/services/get_all.php');
      print('📊 API response: $data');

      if (data['success'] == true && data['data'] != null) {
        final servicesData = data['data']['services'] ?? data['data'];
        print('📋 Services data: $servicesData');

        if (servicesData is List) {
          final result = List<Service>.from(
            servicesData.map((item) => Service.fromJson(item)),
          );
          print('✅ Processed services: ${result.length} services');
          return result;
        } else {
          print('⚠️ Services data is not a List: ${servicesData.runtimeType}');
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error getting all services: $e');
      return [];
    }
  }

  static Future<Service?> getServiceById(int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/services/get_by_id.php?id=$serviceId',
      );
      if (data['success'] == true) {
        return Service.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error getting service by ID: $e');
      return null;
    }
  }

  // Get service details with reviews
  static Future<Map<String, dynamic>> getServiceDetails(int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/services/get_by_id.php?id=$serviceId',
      );
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data']);
      }
      return {};
    } catch (e) {
      print('Error getting service details: $e');
      return {};
    }
  }

  // Get provider info for booking
  static Future<Map<String, dynamic>> getProviderInfo(int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/services/get_provider_info.php?service_id=$serviceId',
      );
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data']);
      }
      return {};
    } catch (e) {
      print('Error getting provider info: $e');
      return {};
    }
  }

  static Future<List<Service>> searchServices(String query) async {
    try {
      final data = await _makeRequest(
        'api/services/search.php?q=${Uri.encodeComponent(query)}',
      );
      if (data['success'] == true) {
        return List<Service>.from(
          data['data'].map((item) => Service.fromJson(item)),
=======
        // إذا لم يكن JSON، قد يكون خطأ في الخادم
        print('Non-JSON Response: ${response.body}');
        throw Exception(
          'الخادم لا يعيد بيانات JSON صحيحة - تأكد من أن الخادم يعمل بشكل صحيح',
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
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

<<<<<<< HEAD
  static Future<bool> cancelBooking(int bookingId) async {
    try {
      final data = await _makeRequest(
        'bookings/cancel_booking.php',
        body: json.encode({'booking_id': bookingId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error canceling booking: $e');
      return false;
    }
  }

  // User methods
  static Future<User?> getUserProfile(int userId) async {
    try {
      final data = await _makeRequest('user/get_profile.php?user_id=$userId');
      if (data['success'] == true) {
        return User.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile(
    int userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final data = await _makeRequest(
        'update_user_profile.php',
        body: json.encode({'user_id': userId, ...profileData}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Update profile with admin approval
  static Future<Map<String, dynamic>> updateProfileWithApproval(
    int userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final data = await _makeRequest(
        'user/update_profile_with_approval.php',
        body: json.encode({'user_id': userId, ...profileData}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم إرسال طلب تحديث البيانات بنجاح',
          'request_id': data['request_id'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في إرسال طلب تحديث البيانات',
        };
      }
    } catch (e) {
      print('Update profile with approval error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Provider methods
  static Future<List<Service>> getProviderServices(int providerId) async {
    try {
      final data = await _makeRequest(
        'get_provider_services.php?provider_id=$providerId',
      );
      if (data['success'] == true) {
        return List<Service>.from(
          data['data'].map((item) => Service.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting provider services: $e');
      return [];
    }
  }

  static Future<bool> addService(Map<String, dynamic> serviceData) async {
    try {
      final data = await _makeRequest(
        'provider/add_service.php',
        body: json.encode(serviceData),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error adding service: $e');
      return false;
    }
  }

  static Future<bool> updateService(
    int serviceId,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      final data = await _makeRequest(
        'update_service.php',
        body: json.encode({'service_id': serviceId, ...serviceData}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  static Future<bool> deleteService(int serviceId) async {
    try {
      final data = await _makeRequest(
        'delete_service.php',
        body: json.encode({'service_id': serviceId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }

  // Ads methods
  static Future<List<AdModel>> getAds() async {
    try {
      final data = await _makeRequest('get_ads.php');
      if (data['success'] == true) {
        return List<AdModel>.from(
          data['data'].map((item) => AdModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting ads: $e');
      return [];
    }
  }

  // Get active ads for homepage
  static Future<List<AdModel>> getActiveAds() async {
    try {
      final data = await _makeRequest(
        'api/ads/get_active_ads.php',
        suppressMessages: true, // إخفاء رسائل API
      );
      if (data['success'] == true) {
        return List<AdModel>.from(
          data['data'].map((item) => AdModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting active ads: $e');
      return [];
    }
  }

  // Get public ads for guests (without login)
  static Future<List<AdModel>> getPublicAds() async {
    try {
      final data = await _makeRequest(
        'api/ads/get_public_ads.php',
        suppressMessages: true, // إخفاء رسائل API
      );
      if (data['success'] == true) {
        return List<AdModel>.from(
          data['data'].map((item) => AdModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting public ads: $e');
      return [];
    }
  }

  // Get simple ads without any authentication
  static Future<List<AdModel>> getSimpleAds() async {
    try {
      final data = await _makeRequest(
        'api/ads/get_simple_ads.php',
        suppressMessages: true, // إخفاء رسائل API
      );
      if (data['success'] == true) {
        return List<AdModel>.from(
          data['data'].map((item) => AdModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting simple ads: $e');
      return [];
    }
  }

  static Future<bool> addAd(Map<String, dynamic> adData) async {
    try {
      final data = await _makeRequest(
        'add_ad.php',
        body: json.encode(adData),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error adding ad: $e');
      return false;
    }
  }

  static Future<bool> updateAd(int adId, Map<String, dynamic> adData) async {
    try {
      final data = await _makeRequest(
        'update_ad.php',
        body: json.encode({'ad_id': adId, ...adData}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error updating ad: $e');
      return false;
    }
  }

  static Future<bool> deleteAd(int adId, {int? providerId}) async {
    try {
      final body = {'ad_id': adId};
      if (providerId != null) {
        body['provider_id'] = providerId;
      }

      final data = await _makeRequest(
        'provider/delete_ad.php',
        body: json.encode(body),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error deleting ad: $e');
      return false;
    }
  }

  // File upload methods
  static Future<String?> uploadFile(
    List<int> fileBytes,
    String fileName,
    String fileType,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/upload_file.php');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
        )
        ..fields['file_type'] = fileType;

      final response = await request.send().timeout(_timeout);
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['file_url'];
      }
      return null;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Statistics methods
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final data = await _makeRequest('get_statistics.php');
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['data']);
      }
      return {};
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // Notifications methods
  static Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    try {
      final data = await _makeRequest(
        'notifications/get_notifications.php?user_id=$userId',
      );
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final data = await _makeRequest(
        'notifications/mark_as_read.php',
        body: json.encode({'notification_id': notificationId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // SMS verification methods
  static Future<bool> verifyCode(String phone, String code) async {
    try {
      final data = await _makeRequest(
        'verify_sms_code.php',
        body: json.encode({'phone': phone, 'code': code}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error verifying SMS code: $e');
      return false;
    }
  }

  static Future<bool> sendSMSCode(String phone) async {
    try {
      final data = await _makeRequest(
        'send_sms_code.php',
        body: json.encode({'phone': phone}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error sending SMS code: $e');
      return false;
    }
  }

  // Join as provider method
  static Future<bool> joinAsProvider(
    String name,
    String phone,
    String service,
  ) async {
    try {
      final data = await _makeRequest(
        'join_as_provider.php',
        body: json.encode({'name': name, 'phone': phone, 'service': service}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error joining as provider: $e');
      return false;
    }
  }

  // Change password method
  static Future<bool> changePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final data = await _makeRequest(
        'change_password.php',
        body: json.encode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Reset password method
=======
  // ==================== استعادة كلمة المرور ====================
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
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

<<<<<<< HEAD
  // Login method
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    String? userType,
  }) async {
    try {
      final data = await _makeRequest(
        'api/auth/login.php',
        body: json.encode({
          'identifier': identifier,
          'password': password,
          if (userType != null) 'user_type': userType,
        }),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Error logging in: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      final data = await _makeRequest(
        'api/auth/register.php',
        body: json.encode(userData),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Error registering: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify account method
  static Future<Map<String, dynamic>> verify({
    required String email,
    required String code,
  }) async {
    try {
      final data = await _makeRequest(
        'api/auth/verify.php',
        body: json.encode({'email': email, 'code': code}),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Error verifying account: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Forgot password method
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final data = await _makeRequest(
        'api/auth/forgot_password.php',
        body: json.encode({'email': email}),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Error forgot password: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reset password method
  static Future<Map<String, dynamic>> resetUserPassword({
    required String email,
    required String code,
=======
  // ==================== تحديث كلمة المرور ====================
  static Future<bool> updatePassword({
    required int userId,
    required String currentPassword,
>>>>>>> cb84a2eea26d79ad48594283002ea73596c659d0
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
