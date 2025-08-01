import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../utils/helpers.dart';

class ReviewsService {
  static const String baseUrl = Config.apiBaseUrl;

  /// الحصول على معرف المستخدم
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('user_id');
    } catch (e) {
      return null;
    }
  }

  /// الحصول على التوكن
  static Future<String?> getToken() async {
    return await Helpers.getToken();
  }

  /// التحقق من أهلية المستخدم للتعليق على خدمة معينة
  static Future<Map<String, dynamic>> checkEligibility(int serviceId) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'يجب تسجيل الدخول أولاً'};
      }

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/reviews/check_eligibility.php?user_id=$userId&service_id=$serviceId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'حدث خطأ في الاتصال'};
      }
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ: $e'};
    }
  }

  /// جلب التقييمات لخدمة معينة
  static Future<Map<String, dynamic>> getReviews(
    int serviceId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/reviews/get_reviews.php?service_id=$serviceId&page=$page&limit=$limit',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'حدث خطأ في الاتصال'};
      }
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ: $e'};
    }
  }

  /// إضافة تقييم جديد
  static Future<Map<String, dynamic>> addReview({
    required int serviceId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) {
        return {'success': false, 'error': 'يجب تسجيل الدخول أولاً'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/reviews/add_review.php'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
        body: json.encode({
          'user_id': userId,
          'service_id': serviceId,
          'rating': rating,
          'comment': comment ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'حدث خطأ في الاتصال'};
      }
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ: $e'};
    }
  }

  /// تنسيق التاريخ
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'منذ ${difference.inMinutes} دقيقة';
        } else {
          return 'منذ ${difference.inHours} ساعة';
        }
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  /// تنسيق التقييم بالنجوم
  static String getRatingText(double rating) {
    if (rating >= 4.5) return 'ممتاز';
    if (rating >= 4.0) return 'جيد جداً';
    if (rating >= 3.5) return 'جيد';
    if (rating >= 3.0) return 'مقبول';
    if (rating >= 2.0) return 'ضعيف';
    return 'سيء';
  }

  /// الحصول على لون التقييم
  static int getRatingColor(double rating) {
    if (rating >= 4.0) return 0xFF4CAF50; // أخضر
    if (rating >= 3.0) return 0xFFFF9800; // برتقالي
    return 0xFFF44336; // أحمر
  }
}
