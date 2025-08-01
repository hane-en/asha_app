import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/api_service.dart';

// اختبار الاتصال بالـ API
class ApiConnectionTest {
  static const String baseUrl = 'http://localhost/new_backend';
  
  // اختبار الاتصال الأساسي
  static Future<void> testBasicConnection() async {
    print('🧪 اختبار الاتصال الأساسي...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response: ${response.body}');
    } catch (e) {
      print('❌ Connection Error: $e');
    }
  }
  
  // اختبار تسجيل الدخول
  static Future<void> testLogin() async {
    print('🧪 اختبار تسجيل الدخول...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': 'haneen242@gmail.com',
          'password': 'Haneeeeen1',
          'user_type': 'user',
        }),
      );
      
      print('✅ Status Code: ${response.statusCode}');
      print('✅ Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Parsed Data: $data');
      }
    } catch (e) {
      print('❌ Login Error: $e');
    }
  }
  
  // اختبار ApiService
  static Future<void> testApiService() async {
    print('🧪 اختبار ApiService...');
    
    try {
      final result = await ApiService.login(
        identifier: 'haneen242@gmail.com',
        password: 'Haneeeeen1',
        userType: 'user',
      );
      
      print('✅ ApiService Result: $result');
    } catch (e) {
      print('❌ ApiService Error: $e');
    }
  }
  
  // اختبار جميع الطرق
  static Future<void> runAllTests() async {
    print('🚀 بدء اختبارات الاتصال...\n');
    
    await testBasicConnection();
    print('');
    
    await testLogin();
    print('');
    
    await testApiService();
    print('');
    
    print('✅ انتهت جميع الاختبارات');
  }
} 