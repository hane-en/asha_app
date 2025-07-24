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

  // Get join requests
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

  // Approve provider
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

  // Get all comments
  static Future<List<Map<String, dynamic>>> getAllComments() async {
    try {
      final data = await _makeRequest('get_all_comments.php');

      return data['success'] == true
          ? List<Map<String, dynamic>>.from(data['data'])
          : [];
    } catch (e) {
      print('Get all comments error: $e');
      return [];
    }
  }

  // Delete comment
  static Future<bool> deleteComment(int commentId) async {
    try {
      final data = await _makeRequest(
        'delete_comment.php',
        body: json.encode({'comment_id': commentId}),
        isPost: true,
      );
      return data['success'] == true;
    } catch (e) {
      print('Delete comment error: $e');
      return false;
    }
  }
}
