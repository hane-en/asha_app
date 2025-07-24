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
  static Future<List<ServiceModel>> getMyServices(int providerId) async {
    try {
      final data = await _makeRequest(
        'get_my_services.php',
        body: json.encode({'provider_id': providerId}),
        isPost: true,
      );

      if (data['success'] == true) {
        return List<ServiceModel>.from(
          data['data'].map((json) => ServiceModel.fromJson(json)),
        );
    } else {
        throw Exception(data['message'] ?? 'فشل تحميل خدماتك');
      }
    } catch (e) {
      print('Get my services error: $e');
      rethrow;
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
    int providerId,
  ) async {
    try {
      final data = await _makeRequest(
        'get_provider_bookings.php?provider_id=$providerId',
      );

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
        'update_booking_status.php',
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
        'get_provider_stats.php?provider_id=$providerId',
      );

      return data['success'] == true ? data['data'] : null;
    } catch (e) {
      print('Get provider stats error: $e');
      return null;
    }
  }

  // Get provider's reviews
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
}
