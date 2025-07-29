import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/config.dart';

class TestServicesSimple extends StatefulWidget {
  @override
  _TestServicesSimpleState createState() => _TestServicesSimpleState();
}

class _TestServicesSimpleState extends State<TestServicesSimple> {
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار بسيط للخدمات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _testDirectApi,
              child: Text('اختبار API مباشر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _result.isEmpty ? 'اضغط على الزر لاختبار جلب الخدمات' : _result,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testDirectApi() async {
    setState(() {
      _isLoading = true;
      _result = 'جاري اختبار API مباشر...\n';
    });

    try {
      final url = '${Config.apiBaseUrl}/api/services/get_all.php';
      print('🔍 Testing URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      setState(() {
        _result += '📊 استجابة API:\n';
        _result += 'Status Code: ${response.statusCode}\n';
        _result += 'URL: $url\n\n';
        
        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            _result += '✅ تم فك تشفير JSON بنجاح\n';
            _result += 'success: ${data['success']}\n';
            _result += 'message: ${data['message'] ?? 'لا يوجد رسالة'}\n\n';
            
            if (data['success'] == true && data['data'] != null) {
              final servicesData = data['data'];
              if (servicesData['services'] is List) {
                final services = servicesData['services'] as List;
                _result += '✅ تم جلب ${services.length} خدمة\n\n';
                
                for (int i = 0; i < services.length && i < 3; i++) {
                  final service = services[i];
                  _result += 'خدمة ${i + 1}:\n';
                  _result += '- ID: ${service['id']}\n';
                  _result += '- العنوان: ${service['title']}\n';
                  _result += '- الوصف: ${service['description']?.substring(0, 50)}...\n';
                  _result += '- السعر: ${service['price']}\n';
                  _result += '- الفئة: ${service['category_name']}\n';
                  _result += '- المزود: ${service['provider_name']}\n';
                  _result += '- الحالة: ${service['is_active'] ? 'نشط' : 'غير نشط'}\n\n';
                }
              } else {
                _result += '❌ البيانات ليست في الشكل المتوقع\n';
                _result += 'services type: ${servicesData['services'].runtimeType}\n';
              }
            } else {
              _result += '❌ فشل في جلب البيانات\n';
              _result += 'data: ${data['data']}\n';
            }
          } catch (e) {
            _result += '❌ خطأ في فك تشفير JSON: $e\n';
            _result += 'Response body: ${response.body}\n';
          }
        } else {
          _result += '❌ خطأ في HTTP: ${response.statusCode}\n';
          _result += 'Response body: ${response.body}\n';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result += '❌ خطأ: $e\n';
        _isLoading = false;
      });
    }
  }
} 