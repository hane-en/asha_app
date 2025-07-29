import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class UnifiedDataService {
  static const String _baseUrl = Config.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Helper method to handle HTTP requests
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool isPost = false,
    bool isPut = false,
    bool isDelete = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'EventServicesApp/${Config.appVersion}',
        ...?headers,
      };

      print(
        '🔍 API Request: ${isPost
            ? 'POST'
            : isPut
            ? 'PUT'
            : isDelete
            ? 'DELETE'
            : 'GET'} $uri',
      );

      http.Response response;
      if (isPost) {
        response = await http
            .post(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else if (isPut) {
        response = await http
            .put(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else if (isDelete) {
        response = await http
            .delete(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else {
        response = await http
            .get(uri, headers: requestHeaders)
            .timeout(_timeout);
      }

      print('📊 API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseData = json.decode(response.body);
          return responseData;
        } catch (e) {
          print('Error parsing JSON response: $e');
          return {'success': false, 'message': 'خطأ في تنسيق البيانات'};
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        return {
          'success': false,
          'message': 'خطأ في الاتصال بالخادم (${response.statusCode})',
        };
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالشبكة'};
    } catch (e) {
      print('API Error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // 🟢 جلب الفئات - نفس الطريقة المستخدمة في user-home
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      print('🔍 Making request to categories API...');
      final data = await _makeRequest('api/services/get_categories.php');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final categoriesData = data['data'];
        print('📋 Categories data: $categoriesData');

        if (categoriesData is List) {
          final result = categoriesData
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print('✅ Processed categories: ${result.length} categories');
          return result;
        } else {
          print(
            '⚠️ Categories data is not a List: ${categoriesData.runtimeType}',
          );
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return [];
    }
  }

  // 🟢 جلب الخدمات - نفس الطريقة المستخدمة في user-home
  static Future<Map<String, dynamic>> getServices({
    int? categoryId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      print('🔍 Fetching services...');
      print(
        '📋 Parameters: categoryId=$categoryId, limit=$limit, offset=$offset',
      );

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      print('🔗 Request URL: api/services/get_all.php?$queryString');

      final data = await _makeRequest('api/services/get_all.php?$queryString');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final servicesData = data['data'];
        print('📋 Services data: $servicesData');

        if (servicesData is List) {
          final result = {
            'services': servicesData,
            'pagination': data['pagination'] ?? {},
          };
          print('✅ Processed services: ${servicesData.length} services');
          return result;
        } else {
          print('⚠️ Services data is not a List: ${servicesData.runtimeType}');
          return {'services': [], 'pagination': {}};
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
        return {'services': [], 'pagination': {}};
      }
    } catch (e) {
      print('❌ Error fetching services: $e');
      return {'services': [], 'pagination': {}};
    }
  }

  // 🟢 جلب الإعلانات
  static Future<List<Map<String, dynamic>>> getAds() async {
    try {
      print('🔍 Making request to ads API...');
      final data = await _makeRequest('api/ads/get_active_ads.php');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final adsData = data['data'];
        print('📋 Ads data: $adsData');

        if (adsData is List) {
          final result = adsData
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print('✅ Processed ads: ${result.length} ads');
          return result;
        } else {
          print('⚠️ Ads data is not a List: ${adsData.runtimeType}');
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching ads: $e');
      return [];
    }
  }

  // 🟢 جلب المستخدمين
  static Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      print('🔍 Making request to users API...');
      final data = await _makeRequest('api/users/get_all.php');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final usersData = data['data'];
        print('📋 Users data: $usersData');

        if (usersData is List) {
          final result = usersData
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print('✅ Processed users: ${result.length} users');
          return result;
        } else {
          print('⚠️ Users data is not a List: ${usersData.runtimeType}');
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  // 🟢 جلب الحجوزات
  static Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      print('🔍 Making request to bookings API...');
      final data = await _makeRequest('api/bookings/get_all.php');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final bookingsData = data['data'];
        print('📋 Bookings data: $bookingsData');

        if (bookingsData is List) {
          final result = bookingsData
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print('✅ Processed bookings: ${result.length} bookings');
          return result;
        } else {
          print('⚠️ Bookings data is not a List: ${bookingsData.runtimeType}');
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      return [];
    }
  }

  // 🟢 جلب التقييمات
  static Future<List<Map<String, dynamic>>> getReviews() async {
    try {
      print('🔍 Making request to reviews API...');
      final data = await _makeRequest('api/reviews/get_all.php');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final reviewsData = data['data'];
        print('📋 Reviews data: $reviewsData');

        if (reviewsData is List) {
          final result = reviewsData
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print('✅ Processed reviews: ${result.length} reviews');
          return result;
        } else {
          print('⚠️ Reviews data is not a List: ${reviewsData.runtimeType}');
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching reviews: $e');
      return [];
    }
  }

  // 🟢 جلب المفضلة
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      print('🔍 Making request to favorites API...');
      final data = await _makeRequest('api/favorites/get_all.php');
      print('📊 API response: $data');

      if (data['success'] == true) {
        final favoritesData = data['data'];
        print('📋 Favorites data: $favoritesData');

        if (favoritesData is List) {
          final result = favoritesData
              .where((item) => item is Map<String, dynamic>)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          print('✅ Processed favorites: ${result.length} favorites');
          return result;
        } else {
          print(
            '⚠️ Favorites data is not a List: ${favoritesData.runtimeType}',
          );
        }
      } else {
        print('❌ API returned success: false - ${data['message']}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching favorites: $e');
      return [];
    }
  }
}
