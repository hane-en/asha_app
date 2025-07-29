import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_category_model.dart';
import '../constants/api_constants.dart';

class ServiceCategoryService {
  static const String baseUrl = ApiConstants.baseUrl;

  // جلب فئات الخدمة لخدمة معينة
  static Future<ServiceCategoryResponse> getServiceCategories(
    int serviceId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/services/get_service_categories.php?service_id=$serviceId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ServiceCategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('فشل في جلب فئات الخدمة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // إضافة فئة خدمة جديدة
  static Future<ServiceCategoryResponse> addServiceCategory(
    Map<String, dynamic> categoryData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/services/add_service_category.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(categoryData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ServiceCategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('فشل في إضافة فئة الخدمة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // تحديث فئة خدمة
  static Future<ServiceCategoryResponse> updateServiceCategory(
    int categoryId,
    Map<String, dynamic> categoryData,
  ) async {
    try {
      categoryData['id'] = categoryId;

      final response = await http.post(
        Uri.parse('$baseUrl/api/services/update_service_category.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(categoryData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ServiceCategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('فشل في تحديث فئة الخدمة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // حذف فئة خدمة
  static Future<bool> deleteServiceCategory(int categoryId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/services/delete_service_category.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'id': categoryId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] ?? false;
      } else {
        throw Exception('فشل في حذف فئة الخدمة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // جلب فئة خدمة واحدة
  static Future<ServiceCategory?> getServiceCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/services/get_service_category.php?id=$categoryId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return ServiceCategory.fromJson(jsonData['data']);
        }
        return null;
      } else {
        throw Exception('فشل في جلب فئة الخدمة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // البحث في فئات الخدمة
  static Future<ServiceCategoryResponse> searchServiceCategories(
    int serviceId,
    String query,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/services/search_service_categories.php?service_id=$serviceId&query=${Uri.encodeComponent(query)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ServiceCategoryResponse.fromJson(jsonData);
      } else {
        throw Exception('فشل في البحث في فئات الخدمة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // جلب فئات الخدمة حسب السعر
  static Future<ServiceCategoryResponse> getServiceCategoriesByPrice(
    int serviceId, {
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      String url =
          '$baseUrl/api/services/get_service_categories_by_price.php?service_id=$serviceId';
      if (minPrice != null) url += '&min_price=$minPrice';
      if (maxPrice != null) url += '&max_price=$maxPrice';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ServiceCategoryResponse.fromJson(jsonData);
      } else {
        throw Exception(
          'فشل في جلب فئات الخدمة حسب السعر: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
