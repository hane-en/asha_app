import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../models/ad_model.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../utils/helpers.dart';

class ProviderApi {
  static const String baseUrl = Config.apiBaseUrl;

  // إضافة إعلان جديد
  static Future<Map<String, dynamic>> addAd({
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> images,
    required String providerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/provider/ads'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'images': images,
          'provider_id': providerId,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل في إضافة الإعلان: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // تحديث إعلان
  static Future<Map<String, dynamic>> updateAd({
    required String adId,
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> images,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/provider/ads/$adId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'images': images,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل في تحديث الإعلان: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // حذف إعلان
  static Future<bool> deleteAd(String adId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/provider/ads/$adId'),
        headers: {
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على إعلانات المزود
  static Future<List<AdModel>> getProviderAds(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provider/$providerId/ads'),
        headers: {
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AdModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في جلب الإعلانات: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // إضافة خدمة جديدة
  static Future<Map<String, dynamic>> addService({
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> images,
    required String providerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/provider/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'images': images,
          'provider_id': providerId,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل في إضافة الخدمة: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // تحديث خدمة
  static Future<Map<String, dynamic>> updateService({
    required String serviceId,
    required String title,
    required String description,
    required double price,
    required String category,
    required List<String> images,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/provider/services/$serviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'price': price,
          'category': category,
          'images': images,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل في تحديث الخدمة: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // حذف خدمة
  static Future<bool> deleteService(String serviceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/provider/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على خدمات المزود
  static Future<List<ServiceModel>> getProviderServices(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provider/$providerId/services'),
        headers: {
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في جلب الخدمات: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على حجوزات المزود
  static Future<List<BookingModel>> getProviderBookings(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provider/$providerId/bookings'),
        headers: {
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في جلب الحجوزات: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // تحديث حالة الحجز
  static Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/provider/bookings/$bookingId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // إرسال رسالة
  static Future<bool> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/provider/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
        body: jsonEncode({
          'receiver_id': receiverId,
          'message': message,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على إحصائيات المزود
  static Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/provider/$providerId/stats'),
        headers: {
          'Authorization': 'Bearer ${await Helpers.getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل في جلب الإحصائيات: ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
} 