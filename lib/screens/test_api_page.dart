import 'package:flutter/material.dart';
import '../../test_api_connection.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار الاتصال بالـ API'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _runTests,
              child: const Text('تشغيل الاختبارات'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'اضغط على زر الاختبار' : _testResults,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
    });

    try {
      await ApiConnectionTest.runAllTests();
      setState(() {
        _testResults = '✅ تم تشغيل الاختبارات بنجاح\n';
        _testResults += 'تحقق من console للتفاصيل';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResults = '❌ خطأ في الاختبارات: $e';
        _isLoading = false;
      });
    }
  }
} 