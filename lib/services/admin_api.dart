import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AdminApi {
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
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

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

      // التحقق من نوع المحتوى
      if (response.headers['content-type']?.contains('application/json') == true) {
        final data = jsonDecode(response.body);
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'حدث خطأ في الطلب');
        }
      } else {
        // إذا لم يكن JSON، قد يكون خطأ في الخادم
        print('Server response: ${response.body}');
        throw Exception('الخادم لا يعيد بيانات JSON صحيحة');
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('خطأ في تنسيق البيانات من الخادم - تأكد من أن الخادم يعمل بشكل صحيح');
      }
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // جلب جميع الحجوزات مع الإحصائيات
  static Future<Map<String, dynamic>> getAllBookingsWithStats({
    String? status,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (status != null) queryParams['status'] = status;

      return await _makeRequest(
        '/api/admin/bookings/get_all_with_stats.php',
        queryParams: queryParams,
      );
    } catch (e) {
      print('Error getting bookings: $e');
      return {
        'success': false,
        'data': [],
        'message': 'غير متوفر حالياً'
      };
    }
  }

  // تحديث حالة الحجز
  static Future<bool> updateBookingStatus(int bookingId, String newStatus) async {
    try {
      final response = await _makeRequest(
        '/api/admin/bookings/update_status.php',
        method: 'POST',
        body: {
          'booking_id': bookingId,
          'status': newStatus,
        },
      );
      return response['success'] == true;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  // حذف الحجز
  static Future<bool> deleteBooking(int bookingId) async {
    try {
      final response = await _makeRequest(
        '/api/admin/bookings/delete.php',
        method: 'DELETE',
        body: {'booking_id': bookingId},
      );
      return response['success'] == true;
    } catch (e) {
      print('Error deleting booking: $e');
      return false;
    }
  }
} 