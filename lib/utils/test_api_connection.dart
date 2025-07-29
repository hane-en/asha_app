import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ApiConnectionTest {
  static Future<Map<String, dynamic>> testCategoriesApi() async {
    try {
      print('🔍 اختبار API الفئات...');
      print('📡 URL: ${Config.apiBaseUrl}/api/services/get_categories.php');

      final response = await http
          .get(
            Uri.parse('${Config.apiBaseUrl}/api/services/get_categories.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Status Code: ${response.statusCode}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ API الفئات يعمل بشكل صحيح');
          print('📊 عدد الفئات: ${data['data']?.length ?? 0}');
          return {
            'success': true,
            'message': 'API الفئات يعمل بشكل صحيح',
            'data': data['data'],
            'count': data['data']?.length ?? 0,
          };
        } else {
          print('❌ API الفئات فشل: ${data['message']}');
          return {
            'success': false,
            'message': 'API الفئات فشل: ${data['message']}',
            'data': [],
            'count': 0,
          };
        }
      } else {
        print('❌ خطأ في استجابة الخادم: ${response.statusCode}');
        return {
          'success': false,
          'message': 'خطأ في استجابة الخادم: ${response.statusCode}',
          'data': [],
          'count': 0,
        };
      }
    } catch (e) {
      print('❌ خطأ في اختبار API الفئات: $e');
      return {
        'success': false,
        'message': 'خطأ في اختبار API الفئات: $e',
        'data': [],
        'count': 0,
      };
    }
  }

  static Future<Map<String, dynamic>> testServerConnection() async {
    try {
      print('🔍 اختبار اتصال الخادم...');
      print('📡 URL: ${Config.apiBaseUrl}/test_server.php');

      final response = await http
          .get(
            Uri.parse('${Config.apiBaseUrl}/test_server.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Status Code: ${response.statusCode}');
      print('📋 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ الخادم يعمل بشكل صحيح');
          return {
            'success': true,
            'message': 'الخادم يعمل بشكل صحيح',
            'data': data,
          };
        } else {
          print('❌ الخادم فشل: ${data['message']}');
          return {
            'success': false,
            'message': 'الخادم فشل: ${data['message']}',
            'data': data,
          };
        }
      } else {
        print('❌ خطأ في استجابة الخادم: ${response.statusCode}');
        return {
          'success': false,
          'message': 'خطأ في استجابة الخادم: ${response.statusCode}',
          'data': {},
        };
      }
    } catch (e) {
      print('❌ خطأ في اختبار الخادم: $e');
      return {
        'success': false,
        'message': 'خطأ في اختبار الخادم: $e',
        'data': {},
      };
    }
  }
}
