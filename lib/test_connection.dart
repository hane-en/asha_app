import 'package:flutter/material.dart';
import 'services/api_service.dart';

class TestConnection extends StatefulWidget {
  @override
  _TestConnectionState createState() => _TestConnectionState();
}

class _TestConnectionState extends State<TestConnection> {
  String _result = 'بدء الاختبار...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختبار الاتصال')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
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

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'بدء اختبار الاتصال...\n';
    });

    try {
      _result += '🔍 اختبار getAllServices...\n';
      final services = await ApiService.getAllServices();
      _result += '✅ تم جلب ${services.length} خدمة\n';

      if (services.isNotEmpty) {
        _result += '📋 أول خدمة: ${services.first.title}\n';
      }

      _result += '\n🔍 اختبار getCategories...\n';
      final categories = await ApiService.getCategories();
      _result += '✅ تم جلب ${categories.length} فئة\n';

      if (categories.isNotEmpty) {
        _result += '📋 أول فئة: ${categories.first['title']}\n';
      }
    } catch (e) {
      _result += '❌ خطأ: $e\n';
    }

    setState(() {
      _isLoading = false;
    });
  }
}
