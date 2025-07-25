import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/ad_model.dart';
import '../config/config.dart';

class ApiService {
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

      if (Config.enableLogging) {
        print(
          'API Request: ${isPost
              ? 'POST'
              : isPut
              ? 'PUT'
              : isDelete
              ? 'DELETE'
              : 'GET'} $uri',
        );
        if (body != null) {
          print('Request Body: $body');
        }
      }

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

      if (Config.enableLogging) {
        print('API Response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception(Config.networkErrorMessage);
    } on TimeoutException {
      throw Exception(Config.timeoutErrorMessage);
    } on FormatException {
      throw Exception('خطأ في تنسيق البيانات');
    } catch (e) {
      if (Config.enableLogging) {
        print('API Error: $e');
      }
      throw Exception(Config.unknownErrorMessage);
    }
  }

  // Favorites methods
  static Future<bool> addToFavorites(int userId, int serviceId) async {
    try {
      final data = await _makeRequest(
        'user/add_to_favorites.php',
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
        'user/remove_favorite.php',
        body: json.encode({'user_id': userId, 'service_id': serviceId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorites(int userId) async {
    try {
      final data = await _makeRequest('user/get_favorites.php?user_id=$userId');
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Services methods
  static Future<List<ServiceModel>> getServicesByCategory(
    String category,
  ) async {
    try {
      final data = await _makeRequest(
        'services/get_services.php?category=$category',
      );
      if (data['success'] == true) {
        return List<ServiceModel>.from(
          data['data'].map((item) => ServiceModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting services by category: $e');
      return [];
    }
  }

  static Future<List<ServiceModel>> getAllServices() async {
    try {
      final data = await _makeRequest('services/get_services.php');
      if (data['success'] == true) {
        return List<ServiceModel>.from(
          data['data'].map((item) => ServiceModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting all services: $e');
      return [];
    }
  }

  static Future<ServiceModel?> getServiceById(int serviceId) async {
    try {
      final data = await _makeRequest('services/get_service.php?id=$serviceId');
      if (data['success'] == true) {
        return ServiceModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error getting service by ID: $e');
      return null;
    }
  }

  static Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final data = await _makeRequest(
        'services/search_services.php?q=${Uri.encodeComponent(query)}',
      );
      if (data['success'] == true) {
        return List<ServiceModel>.from(
          data['data'].map((item) => ServiceModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error searching services: $e');
      return [];
    }
  }

  // البحث المتقدم مع فلترة حسب السعر والموقع
  static Future<Map<String, dynamic>> advancedSearch({
    String? query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    double? userLat,
    double? userLng,
    double? maxDistance,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (userLat != null) {
        queryParams['user_lat'] = userLat.toString();
      }
      if (userLng != null) {
        queryParams['user_lng'] = userLng.toString();
      }
      if (maxDistance != null) {
        queryParams['max_distance'] = maxDistance.toString();
      }
      if (sortBy != null) {
        queryParams['sort_by'] = sortBy;
      }
      if (sortOrder != null) {
        queryParams['sort_order'] = sortOrder;
      }

      queryParams['page'] = page.toString();
      queryParams['limit'] = limit.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final data = await _makeRequest(
        'services/advanced_search.php?$queryString',
      );

      if (data['success'] == true) {
        var services = <ServiceModel>[];
        if (data['data'] != null) {
          services = List<ServiceModel>.from(
            data['data'].map((item) => ServiceModel.fromJson(item)),
          );
        }
        return {
          'services': services,
          'filters': data['filters'] ?? {},
          'pagination': data['pagination'] ?? {},
          'total': data['total'] ?? 0,
        };
      }
      return {
        'services': <ServiceModel>[],
        'filters': {},
        'pagination': {},
        'total': 0,
      };
    } catch (e) {
      print('Error in advanced search: $e');
      return {
        'services': <ServiceModel>[],
        'filters': {},
        'pagination': {},
        'total': 0,
      };
    }
  }

  // جلب الفئات
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final data = await _makeRequest('get_categories.php');
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Bookings methods
  static Future<List<BookingModel>> getBookings(int userId) async {
    try {
      final data = await _makeRequest(
        'bookings/get_user_bookings.php?user_id=$userId',
      );
      if (data['success'] == true) {
        return List<BookingModel>.from(
          data['data'].map((item) => BookingModel.fromJson(item)),
        );
      }
      return [];
    } catch (e) {
      print('Error getting bookings: $e');
      return [];
    }
  }

  static Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final data = await _makeRequest(
        'bookings/create_booking.php',
        body: json.encode(bookingData),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      final data = await _makeRequest(
        'update_booking_status.php',
        body: json.encode({'booking_id': bookingId, 'status': status}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  static Future<bool> cancelBooking(int bookingId) async {
    try {
      final data = await _makeRequest(
        'cancel_booking.php',
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
  static Future<UserModel?> getUserProfile(int userId) async {
    try {
      final data = await _makeRequest('get_user_profile.php?id=$userId');
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
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

  // Provider methods
  static Future<List<ServiceModel>> getProviderServices(int providerId) async {
    try {
      final data = await _makeRequest(
        'get_provider_services.php?provider_id=$providerId',
      );
      if (data['success'] == true) {
        return List<ServiceModel>.from(
          data['data'].map((item) => ServiceModel.fromJson(item)),
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

  static Future<bool> deleteAd(int adId) async {
    try {
      final data = await _makeRequest(
        'delete_ad.php',
        body: json.encode({'ad_id': adId}),
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
  static Future<bool> resetPassword(
    String userIdentifier,
    String newPassword,
  ) async {
    try {
      final data = await _makeRequest(
        'auth/reset_password.php',
        body: json.encode({
          'user_identifier': userIdentifier,
          'new_password': newPassword,
        }),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Add comment method
  static Future<bool> addComment(
    int serviceId,
    String comment,
    double rating,
  ) async {
    try {
      final data = await _makeRequest(
        'reviews/add_review.php',
        body: json.encode({
          'service_id': serviceId,
          'comment': comment,
          'rating': rating,
        }),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  // Delete account method
  static Future<bool> deleteAccount(int userId, String password) async {
    try {
      final data = await _makeRequest(
        'delete_account.php',
        body: json.encode({'user_id': userId, 'password': password}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }
}
