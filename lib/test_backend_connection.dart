import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/config.dart';

class TestBackendConnection extends StatefulWidget {
  @override
  _TestBackendConnectionState createState() => _TestBackendConnectionState();
}

class _TestBackendConnectionState extends State<TestBackendConnection> {
  String _result = 'بدء الاختبار...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختبار الاتصال بالـ Backend')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testBackendConnection,
              child: Text('اختبار الاتصال'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'بدء اختبار الاتصال بالـ Backend...\n';
    });

    try {
      // اختبار الاتصال الأساسي
      _result += '🔍 اختبار الاتصال الأساسي...\n';
      final baseUrl = Config.apiBaseUrl;
      _result += '📡 Base URL: $baseUrl\n';

      // اختبار جلب الخدمات
      _result += '\n🔍 اختبار جلب الخدمات...\n';
      final servicesUrl = '$baseUrl/api/services/get_all.php';
      _result += '📡 Services URL: $servicesUrl\n';

      final servicesResponse = await http
          .get(
            Uri.parse(servicesUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      _result +=
          '📊 Services Response Status: ${servicesResponse.statusCode}\n';
      _result += '📊 Services Response Body: ${servicesResponse.body}\n';

      if (servicesResponse.statusCode == 200) {
        final servicesData = json.decode(servicesResponse.body);
        _result += '✅ تم جلب البيانات بنجاح\n';

        if (servicesData['success'] == true) {
          final services = servicesData['data']['services'] ?? [];
          _result += '📋 عدد الخدمات: ${services.length}\n';

          if (services.isNotEmpty) {
            _result += '📋 أول خدمة: ${services.first['title']}\n';
          }
        } else {
          _result += '❌ API returned success: false\n';
          _result += '📋 Error message: ${servicesData['message']}\n';
        }
      } else {
        _result += '❌ فشل في جلب الخدمات\n';
      }

      // اختبار جلب الفئات
      _result += '\n🔍 اختبار جلب الفئات...\n';
      final categoriesUrl = '$baseUrl/api/services/get_categories.php';
      _result += '📡 Categories URL: $categoriesUrl\n';

      final categoriesResponse = await http
          .get(
            Uri.parse(categoriesUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      _result +=
          '📊 Categories Response Status: ${categoriesResponse.statusCode}\n';
      _result += '📊 Categories Response Body: ${categoriesResponse.body}\n';

      if (categoriesResponse.statusCode == 200) {
        final categoriesData = json.decode(categoriesResponse.body);
        _result += '✅ تم جلب الفئات بنجاح\n';

        if (categoriesData['success'] == true) {
          final categories = categoriesData['data'] ?? [];
          _result += '📋 عدد الفئات: ${categories.length}\n';

          if (categories.isNotEmpty) {
            _result += '📋 أول فئة: ${categories.first['name']}\n';
          }
        } else {
          _result += '❌ API returned success: false\n';
          _result += '📋 Error message: ${categoriesData['message']}\n';
        }
      } else {
        _result += '❌ فشل في جلب الفئات\n';
      }

      // اختبار جلب الإعلانات
      _result += '\n🔍 اختبار جلب الإعلانات...\n';
      final adsUrl = '$baseUrl/api/ads/get_active_ads.php';
      _result += '📡 Ads URL: $adsUrl\n';

      final adsResponse = await http
          .get(
            Uri.parse(adsUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 10));

      _result += '📊 Ads Response Status: ${adsResponse.statusCode}\n';
      _result += '📊 Ads Response Body: ${adsResponse.body}\n';

      if (adsResponse.statusCode == 200) {
        final adsData = json.decode(adsResponse.body);
        _result += '✅ تم جلب الإعلانات بنجاح\n';

        if (adsData['success'] == true) {
          final ads = adsData['data'] ?? [];
          _result += '📋 عدد الإعلانات: ${ads.length}\n';
        } else {
          _result += '❌ API returned success: false\n';
          _result += '📋 Error message: ${adsData['message']}\n';
        }
      } else {
        _result += '❌ فشل في جلب الإعلانات\n';
      }
    } catch (e) {
      _result += '❌ خطأ: $e\n';
    }

    setState(() {
      _isLoading = false;
    });
  }
}
