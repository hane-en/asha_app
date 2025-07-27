import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ConnectionTest {
  static const String baseUrl = Config.apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);

  // اختبار الاتصال الأساسي
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/test_api_connection.php'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      print('Connection Test Status: ${response.statusCode}');
      print('Connection Test Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'status': data['summary']['status'] ?? 'unknown',
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'body': response.body,
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'Network error: Cannot connect to server',
        'suggestion': 'Check if XAMPP is running and IP is correct',
      };
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Timeout: Request took too long',
        'suggestion': 'Check server response time',
      };
    } on FormatException {
      return {
        'success': false,
        'error': 'Invalid JSON response',
        'suggestion': 'Check server response format',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unknown error: $e',
        'suggestion': 'Check server logs',
      };
    }
  }

  // اختبار الفئات
  static Future<Map<String, dynamic>> testCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/services/get_categories.php'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      print('Categories Test Status: ${response.statusCode}');
      print('Categories Test Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] == true,
          'data': data,
          'count': data['data']?.length ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Categories test failed: $e'};
    }
  }

  // اختبار التسجيل
  static Future<Map<String, dynamic>> testRegistration() async {
    try {
      final testData = {
        'name': 'Test User',
        'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        'phone': '777123456',
        'password': 'password123',
        'role': 'user',
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(testData),
          )
          .timeout(timeout);

      print('Registration Test Status: ${response.statusCode}');
      print('Registration Test Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] == true,
          'data': data,
          'message': data['message'] ?? 'No message',
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Registration test failed: $e'};
    }
  }

  // اختبار الإعلانات
  static Future<Map<String, dynamic>> testAds() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/ads/get_active_ads.php'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      print('Ads Test Status: ${response.statusCode}');
      print('Ads Test Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] == true,
          'data': data,
          'count': data['data']?.length ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ads test failed: $e'};
    }
  }

  // اختبار الخدمات
  static Future<Map<String, dynamic>> testServices() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/services/get_all_services.php'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      print('Services Test Status: ${response.statusCode}');
      print('Services Test Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] == true,
          'data': data,
          'count': data['data']?.length ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Services test failed: $e'};
    }
  }

  // اختبار شامل
  static Future<Map<String, dynamic>> runAllTests() async {
    print('🔍 Starting API Connection Tests...');
    print('Base URL: $baseUrl');

    final results = <String, dynamic>{};

    // Test 1: Basic Connection
    print('\n📡 Testing Basic Connection...');
    results['connection'] = await testConnection();

    // Test 2: Categories
    print('\n📂 Testing Categories...');
    results['categories'] = await testCategories();

    // Test 3: Services
    print('\n🛠️ Testing Services...');
    results['services'] = await testServices();

    // Test 4: Ads
    print('\n📢 Testing Ads...');
    results['ads'] = await testAds();

    // Test 5: Registration
    print('\n📝 Testing Registration...');
    results['registration'] = await testRegistration();

    // Summary
    int successCount = 0;
    int errorCount = 0;

    results.forEach((key, value) {
      if (value['success'] == true) {
        successCount++;
      } else {
        errorCount++;
      }
    });

    results['summary'] = {
      'total_tests': results.length,
      'success': successCount,
      'errors': errorCount,
      'status': errorCount == 0 ? 'all_passed' : 'has_errors',
    };

    print('\n📊 Test Summary:');
    print('Total Tests: ${results['summary']['total_tests']}');
    print('Success: ${results['summary']['success']}');
    print('Errors: ${results['summary']['errors']}');
    print('Status: ${results['summary']['status']}');

    return results;
  }

  // اختبار رقم الهاتف
  static Future<Map<String, dynamic>> testPhoneValidation() async {
    final testPhones = [
      '777123456', // صحيح
      '781234567', // صحيح
      '77712345', // خاطئ (8 أرقام)
      '767123456', // خاطئ (يبدأ بـ 76)
      '777-123-456', // خاطئ (يحتوي على شرطات)
      '777 123 456', // خاطئ (يحتوي على مسافات)
    ];

    final results = <String, dynamic>{};

    for (final phone in testPhones) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/register.php'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': 'Test User',
                'email':
                    'test${DateTime.now().millisecondsSinceEpoch}@example.com',
                'phone': phone,
                'password': 'password123',
                'role': 'user',
              }),
            )
            .timeout(timeout);

        final data = json.decode(response.body);
        results[phone] = {
          'status': data['success'] == true ? 'accepted' : 'rejected',
          'message': data['message'] ?? 'No message',
          'http_code': response.statusCode,
        };
      } catch (e) {
        results[phone] = {
          'status': 'error',
          'message': 'Test failed: $e',
          'http_code': 0,
        };
      }
    }

    return results;
  }
}
