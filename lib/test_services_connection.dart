import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/services_service.dart';
import 'models/service_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestServicesConnection extends StatefulWidget {
  @override
  _TestServicesConnectionState createState() => _TestServicesConnectionState();
}

class _TestServicesConnectionState extends State<TestServicesConnection> {
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار جلب الخدمات'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _testApiService,
              child: Text('اختبار ApiService.getAllServices()'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testServicesService,
              child: Text('اختبار ServicesService.getAllServices()'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testDirectApi,
              child: Text('اختبار API مباشر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
                      _result.isEmpty
                          ? 'اضغط على أحد الأزرار لاختبار جلب الخدمات'
                          : _result,
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

  Future<void> _testApiService() async {
    setState(() {
      _isLoading = true;
      _result = 'جاري اختبار ApiService.getAllServices()...\n';
    });

    try {
      final services = await ApiService.getAllServices();
      setState(() {
        _result += '✅ تم جلب ${services.length} خدمة\n\n';
        for (int i = 0; i < services.length && i < 5; i++) {
          final service = services[i];
          _result += 'خدمة ${i + 1}:\n';
          _result += '- العنوان: ${service.title}\n';
          _result += '- الوصف: ${service.description?.substring(0, 50)}...\n';
          _result += '- السعر: ${service.price}\n';
          _result += '- الفئة: ${service.categoryName}\n';
          _result += '- المزود: ${service.providerName}\n\n';
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

  Future<void> _testServicesService() async {
    setState(() {
      _isLoading = true;
      _result = 'جاري اختبار ServicesService.getAllServices()...\n';
    });

    try {
      final servicesService = ServicesService();
      final response = await servicesService.getAllServices(page: 1, limit: 10);

      setState(() {
        _result += '📊 استجابة API:\n';
        _result += 'success: ${response['success']}\n';
        _result += 'message: ${response['message'] ?? 'لا يوجد رسالة'}\n\n';

        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          if (data['services'] is List) {
            final services = data['services'] as List;
            _result += '✅ تم جلب ${services.length} خدمة\n\n';

            for (int i = 0; i < services.length && i < 3; i++) {
              final service = services[i];
              _result += 'خدمة ${i + 1}:\n';
              _result += '- العنوان: ${service['title']}\n';
              _result +=
                  '- الوصف: ${service['description']?.substring(0, 50)}...\n';
              _result += '- السعر: ${service['price']}\n';
              _result += '- الفئة: ${service['category_name']}\n';
              _result += '- المزود: ${service['provider_name']}\n\n';
            }
          } else {
            _result += '❌ البيانات ليست في الشكل المتوقع\n';
          }
        } else {
          _result += '❌ فشل في جلب البيانات\n';
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

  Future<void> _testDirectApi() async {
    setState(() {
      _isLoading = true;
      _result = 'جاري اختبار API مباشر...\n';
    });

    try {
      // استخدام http مباشرة للاختبار
      final response = await http.get(
        Uri.parse('http://localhost/asha_app_backend/api/services/get_all.php'),
      );

      setState(() {
        _result += '📊 استجابة API المباشر:\n';
        _result += 'Status Code: ${response.statusCode}\n';
        _result += 'Response Body: ${response.body}\n\n';

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
                  _result += '- العنوان: ${service['title']}\n';
                  _result +=
                      '- الوصف: ${service['description']?.substring(0, 50)}...\n';
                  _result += '- السعر: ${service['price']}\n';
                  _result += '- الفئة: ${service['category_name']}\n';
                  _result += '- المزود: ${service['provider_name']}\n\n';
                }
              } else {
                _result += '❌ البيانات ليست في الشكل المتوقع\n';
              }
            } else {
              _result += '❌ فشل في جلب البيانات\n';
            }
          } catch (e) {
            _result += '❌ خطأ في فك تشفير JSON: $e\n';
          }
        } else {
          _result += '❌ خطأ في HTTP: ${response.statusCode}\n';
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
