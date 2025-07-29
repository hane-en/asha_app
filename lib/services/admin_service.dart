import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../constants/api_constants.dart';

class AdminService {
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

  // Get provider requests
  static Future<Map<String, dynamic>> getProviderRequests({
    int page = 1,
    String? status,
  }) async {
    try {
      String endpoint = 'api/admin/get_provider_requests.php?page=$page';
      if (status != null) {
        endpoint += '&status=$status';
      }

      final data = await _makeRequest(endpoint);

      if (data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'stats': data['stats'] ?? {},
          'pagination': data['pagination'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تحميل طلبات مزودي الخدمة',
        };
      }
    } catch (e) {
      print('Get provider requests error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get join requests (legacy)
  static Future<List<dynamic>> getJoinRequests() async {
    try {
      final data = await _makeRequest('get_join_requests.php');

      if (data['success'] == true) {
        return List<dynamic>.from(data['data'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'فشل تحميل طلبات الانضمام');
      }
    } catch (e) {
      print('Get join requests error: $e');
      rethrow;
    }
  }

  // Delete provider request
  static Future<Map<String, dynamic>> deleteProviderRequest(
    int requestId,
  ) async {
    try {
      final data = await _makeRequest(
        'admin/delete_provider_request.php',
        body: json.encode({'request_id': requestId}),
        isPost: true,
      );

      return data['success'] == true
          ? {
              'success': true,
              'message': data['message'] ?? 'تم حذف الطلب بنجاح',
            }
          : {
              'success': false,
              'message': data['message'] ?? 'فشل في حذف الطلب',
            };
    } catch (e) {
      print('Delete provider request error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final data = await _makeRequest('api/admin/get_all_users.php');

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  // Get users by role
  static Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    try {
      final data = await _makeRequest(
        'api/admin/get_users_by_role.php?role=$role',
      );

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get users by role error: $e');
      return [];
    }
  }

  // Block user
  static Future<bool> blockUser(int userId, String reason) async {
    try {
      final data = await _makeRequest(
        'api/admin/block_user.php',
        body: json.encode({'user_id': userId, 'reason': reason}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Block user error: $e');
      return false;
    }
  }

  // Unblock user
  static Future<bool> unblockUser(int userId) async {
    try {
      final data = await _makeRequest(
        'api/admin/unblock_user.php',
        body: json.encode({'user_id': userId}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Unblock user error: $e');
      return false;
    }
  }

  // Delete user
  static Future<Map<String, dynamic>> deleteUser(
    int userId,
    String reason,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/delete_user.php',
        body: json.encode({'user_id': userId, 'reason': reason}),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Delete user error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Search users
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final data = await _makeRequest('api/admin/search_user.php?query=$query');

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Search users error: $e');
      return [];
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(
    String userId,
    String name,
    String phone,
    String password,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/update_user_profile.php',
        body: json.encode({
          'user_id': userId,
          'name': name,
          'phone': phone,
          'password': password,
        }),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Update user profile error: $e');
      return false;
    }
  }

  // Get all services
  static Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final data = await _makeRequest('api/services/get_all.php');

      return data['success'] == true &&
              data['data'] != null &&
              data['data']['services'] != null
          ? List<Map<String, dynamic>>.from(data['data']['services'])
          : [];
    } catch (e) {
      print('Get all services error: $e');
      return [];
    }
  }

  // Get all ads
  static Future<List<Map<String, dynamic>>> getAllAds() async {
    try {
      final data = await _makeRequest('api/admin/get_all_ads.php');

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all ads error: $e');
      return [];
    }
  }

  // Get all bookings
  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final data = await _makeRequest('api/admin/get_all_bookings.php');

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all bookings error: $e');
      return [];
    }
  }

  // Get all reviews
  static Future<List<Map<String, dynamic>>> getAllReviews() async {
    try {
      final data = await _makeRequest('api/admin/get_all_reviews.php');

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all reviews error: $e');
      return [];
    }
  }

  // Get provider requests list
  static Future<List<Map<String, dynamic>>> getProviderRequestsList() async {
    try {
      final data = await _makeRequest('api/admin/get_provider_requests.php');

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get provider requests error: $e');
      return [];
    }
  }

  // Approve service
  static Future<bool> approveService(int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/admin/approve_service.php',
        body: json.encode({'service_id': serviceId}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Approve service error: $e');
      return false;
    }
  }

  // Reject service
  static Future<bool> rejectService(int serviceId, String reason) async {
    try {
      final data = await _makeRequest(
        'api/admin/reject_service.php',
        body: json.encode({'service_id': serviceId, 'reason': reason}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Reject service error: $e');
      return false;
    }
  }

  // Delete service
  static Future<bool> deleteService(int serviceId) async {
    try {
      final data = await _makeRequest(
        'api/admin/delete_service.php',
        body: json.encode({'service_id': serviceId}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Delete service error: $e');
      return false;
    }
  }

  // Delete service with notification
  static Future<Map<String, dynamic>> deleteServiceWithNotification(
    int serviceId,
    String reason,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/delete_service.php',
        body: json.encode({'service_id': serviceId, 'reason': reason}),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Delete service with notification error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete service category
  static Future<bool> deleteServiceCategory(int categoryId) async {
    try {
      final data = await _makeRequest(
        'api/services/delete_service_category.php',
        body: json.encode({'id': categoryId}),
        isPost: true,
      );

      return data['success'] ?? false;
    } catch (e) {
      print('Delete service category error: $e');
      return false;
    }
  }

  // Update booking status
  static Future<bool> updateBookingStatus(
    int bookingId,
    String newStatus,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/update_booking_status.php',
        body: json.encode({'booking_id': bookingId, 'status': newStatus}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Update booking status error: $e');
      return false;
    }
  }

  // Delete booking
  static Future<bool> deleteBooking(int bookingId) async {
    try {
      final data = await _makeRequest(
        'api/admin/delete_booking.php',
        body: json.encode({'booking_id': bookingId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Delete booking error: $e');
      return false;
    }
  }

  // Get bookings by status
  static Future<List<Map<String, dynamic>>> getBookingsByStatus(
    String status,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/get_all_bookings.php?status=$status',
      );

      return data['success'] == true && data['data'] != null
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get bookings by status error: $e');
      return [];
    }
  }

  // Get all reviews organized by categories and services
  static Future<Map<String, dynamic>> getAllReviewsDetailed() async {
    try {
      final data = await _makeRequest('api/admin/get_all_reviews.php');

      if (data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'stats': data['stats'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب التعليقات',
        };
      }
    } catch (e) {
      print('Get all reviews error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete review with notification
  static Future<Map<String, dynamic>> deleteReviewWithNotification({
    required int reviewId,
    String? reason,
  }) async {
    try {
      final data = await _makeRequest(
        'api/admin/delete_review.php',
        body: json.encode({'review_id': reviewId, 'reason': reason}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف التعليق بنجاح',
          'data': data['data'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في حذف التعليق',
        };
      }
    } catch (e) {
      print('Delete review error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Legacy methods for backward compatibility
  static Future<List<Map<String, dynamic>>> getAllComments() async {
    try {
      final result = await getAllReviewsDetailed();
      if (result['success'] == true) {
        // Convert the new format to the old format for compatibility
        List<Map<String, dynamic>> comments = [];
        final data = result['data'] ?? [];
        for (var category in data) {
          for (var service in category['services'] ?? []) {
            for (var review in service['reviews'] ?? []) {
              comments.add({
                'id': review['review_id'],
                'content': review['review_comment'],
                'user_name': review['user_name'],
                'service_name': service['service_title'],
                'created_at': review['review_date'],
              });
            }
          }
        }
        return comments;
      }
      return [];
    } catch (e) {
      print('Get all comments error: $e');
      return [];
    }
  }

  static Future<bool> deleteComment(int commentId) async {
    try {
      final result = await deleteReviewWithNotification(reviewId: commentId);
      return result['success'] == true;
    } catch (e) {
      print('Delete comment error: $e');
      return false;
    }
  }

  // Get pending payments
  static Future<Map<String, dynamic>> getPendingPayments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final data = await _makeRequest(
        'api/admin/get_pending_payments.php?page=$page&limit=$limit',
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'data': data['data'] ?? [],
          'stats': data['stats'] ?? {},
          'pagination': data['pagination'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب الدفعات المعلقة',
        };
      }
    } catch (e) {
      print('Get pending payments error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify payment
  static Future<Map<String, dynamic>> verifyPayment({
    required int bookingId,
    required String status,
    String? notes,
  }) async {
    try {
      final data = await _makeRequest(
        'api/admin/verify_payment.php',
        body: json.encode({
          'booking_id': bookingId,
          'verification_status': status,
          'verification_notes': notes,
        }),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم التحقق من الدفع بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في التحقق من الدفع',
        };
      }
    } catch (e) {
      print('Verify payment error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get profile update requests
  static Future<Map<String, dynamic>> getProfileRequests(int page) async {
    try {
      final data = await _makeRequest(
        'api/admin/get_profile_requests.php?page=$page',
      );

      return data['success'] == true
          ? {
              'success': true,
              'data': data['data'] ?? [],
              'pagination': data['pagination'] ?? {},
            }
          : {
              'success': false,
              'message': data['message'] ?? 'فشل في جلب طلبات تحديث البيانات',
            };
    } catch (e) {
      print('Get profile requests error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Handle profile update request (approve/reject)
  static Future<Map<String, dynamic>> handleProfileRequest(
    int requestId,
    String action,
    String adminNotes,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/manage_profile_requests.php',
        body: json.encode({
          'request_id': requestId,
          'action': action,
          'admin_notes': adminNotes,
        }),
        isPost: true,
      );

      return data['success'] == true
          ? {
              'success': true,
              'message': data['message'] ?? 'تم معالجة الطلب بنجاح',
            }
          : {
              'success': false,
              'message': data['message'] ?? 'فشل في معالجة الطلب',
            };
    } catch (e) {
      print('Handle profile request error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get all services with categories
  static Future<Map<String, dynamic>> getAllServicesWithCategories() async {
    try {
      final data = await _makeRequest('api/admin/get_all_services_simple.php');

      if (data['success'] == true) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب الخدمات',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Approve provider request
  static Future<bool> approveProviderRequest(
    int requestId, {
    String? adminNotes,
  }) async {
    try {
      final data = await _makeRequest(
        'api/admin/approve_provider_request.php',
        body: json.encode({
          'request_id': requestId,
          'admin_notes': adminNotes ?? '',
        }),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Approve provider request error: $e');
      return false;
    }
  }

  // Reject provider request
  static Future<bool> rejectProviderRequest(
    int requestId, {
    String? adminNotes,
  }) async {
    try {
      final data = await _makeRequest(
        'api/admin/reject_provider_request.php',
        body: json.encode({
          'request_id': requestId,
          'admin_notes': adminNotes ?? '',
        }),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Reject provider request error: $e');
      return false;
    }
  }

  // Delete ad with notification
  static Future<Map<String, dynamic>> deleteAdWithNotification(
    int adId,
    String reason,
  ) async {
    try {
      final data = await _makeRequest(
        'api/admin/delete_ad.php',
        body: json.encode({'ad_id': adId, 'reason': reason}),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Delete ad with notification error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
