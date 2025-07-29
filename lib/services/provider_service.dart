import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../models/service_model.dart';

class ProviderService {
  static const String _baseUrl = Config.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Helper method to handle HTTP requests
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool isPost = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/$endpoint');
      final requestHeaders = {'Content-Type': 'application/json', ...?headers};

      http.Response response;
      if (isPost) {
        response = await http
            .post(uri, headers: requestHeaders, body: body)
            .timeout(_timeout);
      } else {
        response = await http
            .get(uri, headers: requestHeaders)
            .timeout(_timeout);
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception(Config.networkErrorMessage);
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال');
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات');
    } catch (e) {
      throw Exception(Config.unknownErrorMessage);
    }
  }

  // Get provider's services
  static Future<List<Service>> getMyServices(int providerId) async {
    try {
      final data = await _makeRequest(
        'provider/get_my_services.php?provider_id=$providerId',
      );
      if (data['success'] == true) {
        return List<Service>.from(
          data['data'].map((json) => Service.fromJson(json)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting my services: $e');
      return [];
    }
  }

  // Add new service
  static Future<bool> addService(Map<String, dynamic> serviceData) async {
    try {
      final data = await _makeRequest(
        'add_service.php',
        body: json.encode(serviceData),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Add service error: $e');
      return false;
    }
  }

  // Update service
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
      print('Update service error: $e');
      return false;
    }
  }

  // Delete service
  static Future<bool> deleteService(int serviceId) async {
    try {
      final data = await _makeRequest(
        'delete_service.php',
        body: json.encode({'service_id': serviceId}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Delete service error: $e');
      return false;
    }
  }

  // Get provider's bookings
  static Future<List<Map<String, dynamic>>> getMyBookings(
    int providerId, {
    String? status,
  }) async {
    try {
      String url = 'provider/get_provider_bookings.php?provider_id=$providerId';
      if (status != null) {
        url += '&status=$status';
      }

      final data = await _makeRequest(url);

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get my bookings error: $e');
      return [];
    }
  }

  // Update booking status
  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final data = await _makeRequest(
        'bookings/update_booking_status.php',
        body: json.encode({'booking_id': bookingId, 'status': status}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Update booking status error: $e');
      return false;
    }
  }

  // Get provider's ads
  static Future<List<Map<String, dynamic>>> getMyAds(int providerId) async {
    try {
      final data = await _makeRequest(
        'get_provider_ads.php?provider_id=$providerId',
      );

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get my ads error: $e');
      return [];
    }
  }

  // Add new ad
  static Future<bool> addAd(Map<String, dynamic> adData) async {
    try {
      final data = await _makeRequest(
        'add_ad.php',
        body: json.encode(adData),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Add ad error: $e');
      return false;
    }
  }

  // Update ad
  static Future<bool> updateAd(int adId, Map<String, dynamic> adData) async {
    try {
      final data = await _makeRequest(
        'update_ad.php',
        body: json.encode({'ad_id': adId, ...adData}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Update ad error: $e');
      return false;
    }
  }

  // Delete ad
  static Future<bool> deleteAd(int adId) async {
    try {
      final data = await _makeRequest(
        'delete_ad.php',
        body: json.encode({'ad_id': adId}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Delete ad error: $e');
      return false;
    }
  }

  // Get provider's statistics
  static Future<Map<String, dynamic>?> getProviderStats(int providerId) async {
    try {
      final data = await _makeRequest(
        'provider/get_provider_stats.php?provider_id=$providerId',
      );

      return data['success'] == true ? data['stats'] : null;
    } catch (e) {
      print('Get provider stats error: $e');
      return null;
    }
  }

  // Get provider's detailed statistics
  static Future<Map<String, dynamic>> getProviderDetailedStats(
    int providerId,
  ) async {
    try {
      final data = await _makeRequest(
        'provider/get_provider_stats.php?provider_id=$providerId',
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'stats': data['stats'],
          'recent_bookings': data['recent_bookings'],
          'recent_services': data['recent_services'],
          'recent_ads': data['recent_ads'],
          'recent_reviews': data['recent_reviews'],
          'monthly_stats': data['monthly_stats'],
          'top_services': data['top_services'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'فشل في جلب الإحصائيات',
        };
      }
    } catch (e) {
      print('Get provider detailed stats error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get provider's reviews with services
  static Future<Map<String, dynamic>> getProviderReviewsWithServices({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final data = await _makeRequest(
        'provider/get_provider_reviews.php?page=$page&limit=$limit',
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
          'stats': data['stats'],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب التعليقات',
        };
      }
    } catch (e) {
      print('Get provider reviews with services error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get provider's reviews (legacy)
  static Future<List<Map<String, dynamic>>> getProviderReviews(
    int providerId,
  ) async {
    try {
      final data = await _makeRequest(
        'get_provider_reviews.php?provider_id=$providerId',
      );

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get provider reviews error: $e');
      return [];
    }
  }

  // Update provider profile
  static Future<bool> updateProviderProfile(
    int providerId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final data = await _makeRequest(
        'update_provider_profile.php',
        body: json.encode({'provider_id': providerId, ...profileData}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Update provider profile error: $e');
      return false;
    }
  }

  // جلب خدمات المزود مع التعليقات
  static Future<List<Map<String, dynamic>>> getMyServicesWithReviews() async {
    try {
      final data = await _makeRequest('provider/get_my_services.php');
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting provider services with reviews: $e');
      return [];
    }
  }

  // جلب خدمات المزود مع فئاتها
  static Future<List<Map<String, dynamic>>>
  getMyServicesWithCategories() async {
    try {
      final data = await _makeRequest(
        'provider/get_my_services_with_categories.php',
      );
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting provider services with categories: $e');
      return [];
    }
  }
}
