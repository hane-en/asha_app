import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/config.dart';

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
      String endpoint = 'admin/get_provider_requests.php?page=$page';
      if (status != null) {
        endpoint += '&status=$status';
      }

      final data = await _makeRequest(endpoint);

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
        return List<dynamic>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'فشل تحميل طلبات الانضمام');
      }
    } catch (e) {
      print('Get join requests error: $e');
      rethrow;
    }
  }

  // Approve provider request
  static Future<Map<String, dynamic>> approveProviderRequest(
    int requestId, {
    String? adminNotes,
  }) async {
    try {
      final data = await _makeRequest(
        'admin/manage_provider_requests.php',
        body: json.encode({
          'request_id': requestId,
          'status': 'approved',
          'admin_notes': adminNotes ?? '',
        }),
        isPost: true,
      );

      return data['success'] == true
          ? {
              'success': true,
              'message': data['message'] ?? 'تم الموافقة على الطلب بنجاح',
            }
          : {
              'success': false,
              'message': data['message'] ?? 'فشل في الموافقة على الطلب',
            };
    } catch (e) {
      print('Approve provider request error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reject provider request
  static Future<Map<String, dynamic>> rejectProviderRequest(
    int requestId, {
    String? adminNotes,
  }) async {
    try {
      final data = await _makeRequest(
        'admin/manage_provider_requests.php',
        body: json.encode({
          'request_id': requestId,
          'status': 'rejected',
          'admin_notes': adminNotes ?? '',
        }),
        isPost: true,
      );

      return data['success'] == true
          ? {
              'success': true,
              'message': data['message'] ?? 'تم رفض الطلب بنجاح',
            }
          : {
              'success': false,
              'message': data['message'] ?? 'فشل في رفض الطلب',
            };
    } catch (e) {
      print('Reject provider request error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Approve provider (legacy)
  static Future<bool> approveProvider(int id) async {
    try {
      final data = await _makeRequest(
        'approve_provider.php',
        body: json.encode({'id': id}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Approve provider error: $e');
      return false;
    }
  }

  // Reject provider
  static Future<bool> rejectProvider(int id, String reason) async {
    try {
      final data = await _makeRequest(
        'reject_provider.php',
        body: json.encode({'id': id, 'reason': reason}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Reject provider error: $e');
      return false;
    }
  }

  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final data = await _makeRequest('get_all_users.php');

      return data['success'] == true
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
      final data = await _makeRequest('get_users_by_role.php?role=$role');

      return data['success'] == true
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
        'block_user.php',
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
        'unblock_user.php',
        body: json.encode({'user_id': userId}),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Unblock user error: $e');
      return false;
    }
  }

  // Get all services
  static Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final data = await _makeRequest('get_all_services.php');

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all services error: $e');
      return [];
    }
  }

  // Approve service
  static Future<bool> approveService(int serviceId) async {
    try {
      final data = await _makeRequest(
        'approve_service.php',
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
        'reject_service.php',
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

  // Get all bookings
  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final data = await _makeRequest('get_all_bookings.php');

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all bookings error: $e');
      return [];
    }
  }

  // Get bookings by status
  static Future<List<Map<String, dynamic>>> getBookingsByStatus(
    String status,
  ) async {
    try {
      final data = await _makeRequest(
        'get_bookings_by_status.php?status=$status',
      );

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get bookings by status error: $e');
      return [];
    }
  }

  // Get admin statistics
  static Future<Map<String, dynamic>?> getAdminStats() async {
    try {
      final data = await _makeRequest('get_admin_stats.php');

      return data['success'] == true ? data['data'] : null;
    } catch (e) {
      print('Get admin stats error: $e');
      return null;
    }
  }

  // Get system logs
  static Future<List<Map<String, dynamic>>> getSystemLogs() async {
    try {
      final data = await _makeRequest('get_system_logs.php');

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get system logs error: $e');
      return [];
    }
  }

  // Send notification to users
  static Future<bool> sendNotification({
    required String title,
    required String message,
    List<int>? userIds,
    String? userRole,
  }) async {
    try {
      final data = await _makeRequest(
        'send_notification.php',
        body: json.encode({
          'title': title,
          'message': message,
          'user_ids': userIds,
          'user_role': userRole,
        }),
        isPost: true,
      );

      return data['success'] == true;
    } catch (e) {
      print('Send notification error: $e');
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
        'delete_user.php',
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
      final data = await _makeRequest('search_user.php?query=$query');

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Search users error: $e');
      return [];
    }
  }

  // Update booking status
  static Future<bool> updateBookingStatus(
    int bookingId,
    String newStatus,
  ) async {
    try {
      final data = await _makeRequest(
        'update_booking_status.php',
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
        'delete_booking.php',
        body: json.encode({'booking_id': bookingId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Delete booking error: $e');
      return false;
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
        'update_user_profile.php',
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

  // Get all reviews organized by categories and services
  static Future<Map<String, dynamic>> getAllReviews() async {
    try {
      final data = await _makeRequest('admin/get_all_reviews.php');

      if (data['success'] == true) {
        return {'success': true, 'data': data['data'], 'stats': data['stats']};
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
        'admin/delete_review.php',
        body: json.encode({'review_id': reviewId, 'reason': reason}),
        isPost: true,
      );

      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم حذف التعليق بنجاح',
          'data': data['data'],
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
      final result = await getAllReviews();
      if (result['success'] == true) {
        // Convert the new format to the old format for compatibility
        List<Map<String, dynamic>> comments = [];
        for (var category in result['data']) {
          for (var service in category['services']) {
            for (var review in service['reviews']) {
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
        'admin/get_pending_payments.php?page=$page&limit=$limit',
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
        'admin/verify_payment.php',
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
        'admin/manage_profile_requests.php?page=$page',
      );

      return data['success'] == true
          ? {
              'success': true,
              'data': data['data'],
              'pagination': data['pagination'],
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
        'admin/manage_profile_requests.php',
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

  // Get all services with detailed information
  static Future<Map<String, dynamic>> getAllServicesDetailed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await _makeRequest(
        'admin/get_all_services.php?page=$page&limit=$limit',
      );
      return data;
    } catch (e) {
      print('Get all services detailed error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete service with notification
  static Future<Map<String, dynamic>> deleteServiceWithNotification(
    int serviceId,
    String reason,
  ) async {
    try {
      final data = await _makeRequest(
        'admin/delete_service.php',
        body: json.encode({'service_id': serviceId, 'reason': reason}),
        isPost: true,
      );
      return data;
    } catch (e) {
      print('Delete service with notification error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
