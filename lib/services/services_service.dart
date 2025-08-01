import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../config/config.dart';

class ServicesService {
  final String baseUrl = Config.apiBaseUrl;

  Future<Map<String, dynamic>> getAllServices({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('🔍 Loading services...');
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null) queryParams['search'] = search;
      if (location != null)
        queryParams['city'] = location; // تغيير من location إلى city
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final uri = Uri.parse('$baseUrl/api/services/get_all.php?$queryString');
      print('📡 Request URL: $uri');

      final response = await http.get(uri);

      print('📊 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Services data: $data');

        // التأكد من أن البيانات في الشكل الصحيح
        if (data['success'] == true) {
          return {'success': true, 'data': data['data'] ?? data};
        } else {
          print('❌ API returned success: false');
          return {
            'success': false,
            'message': data['message'] ?? 'فشل في تحميل الخدمات',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {'success': false, 'message': 'فشل في تحميل الخدمات'};
      }
    } catch (e) {
      print('❌ Error loading services: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getServiceById(int serviceId) async {
    try {
      print('🔍 Loading service by ID: $serviceId');
      final uri = Uri.parse(
        '$baseUrl/api/services/get_by_id.php?id=$serviceId',
      );
      print('📡 Request URL: $uri');

      final response = await http.get(uri);

      print('📊 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Service data: $data');
        return {'success': true, 'data': data};
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {'success': false, 'message': 'فشل في تحميل تفاصيل الخدمة'};
      }
    } catch (e) {
      print('❌ Error loading service: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getServicesByCategory(
    int categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Loading services by category: $categoryId');
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'category_id': categoryId.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final uri = Uri.parse('$baseUrl/api/services/get_all.php?$queryString');
      print('📡 Request URL: $uri');

      final response = await http.get(uri);

      print('📊 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Category services data: $data');
        
        // التأكد من أن البيانات في الشكل الصحيح
        if (data['success'] == true) {
          return {'success': true, 'data': data['data'] ?? data};
        } else {
          print('❌ API returned success: false');
          return {
            'success': false,
            'message': data['message'] ?? 'فشل في تحميل خدمات الفئة',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {'success': false, 'message': 'فشل في تحميل خدمات الفئة'};
      }
    } catch (e) {
      print('❌ Error loading category services: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> searchServices(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/services/search',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'فشل في البحث عن الخدمات'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getFeaturedServices() async {
    try {
      final uri = Uri.parse('$baseUrl/services/featured');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'فشل في تحميل الخدمات المميزة'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
