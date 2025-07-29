import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestLoginStatus extends StatefulWidget {
  const TestLoginStatus({super.key});

  @override
  State<TestLoginStatus> createState() => _TestLoginStatusState();
}

class _TestLoginStatusState extends State<TestLoginStatus> {
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
      _result = 'فحص حالة تسجيل الدخول...\n';
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // فحص user_id
      final userId = prefs.getInt('user_id');
      _result += 'User ID: ${userId ?? 'غير محدد'}\n';

      // فحص user_name
      final userName = prefs.getString('user_name');
      _result += 'User Name: ${userName ?? 'غير محدد'}\n';

      // فحص user_type
      final userType = prefs.getString('user_type');
      _result += 'User Type: ${userType ?? 'غير محدد'}\n';

      // فحص auth_token
      final authToken = prefs.getString('auth_token');
      _result += 'Auth Token: ${authToken != null ? 'موجود' : 'غير موجود'}\n';

      // فحص user_data
      final userData = prefs.getString('user_data');
      _result += 'User Data: ${userData != null ? 'موجود' : 'غير موجود'}\n';

      if (userId != null && userId > 0) {
        _result += '✅ المستخدم مسجل دخول\n';
        _result += '💡 يمكن استخدام المفضلة الآن\n';
      } else {
        _result += '❌ المستخدم غير مسجل دخول\n';
        _result += '💡 يجب تسجيل الدخول أولاً\n';
      }
    } catch (e) {
      _result += '❌ خطأ: $e\n';
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص حالة تسجيل الدخول'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_result, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ElevatedButton(
              onPressed: _checkLoginStatus,
              child: const Text('إعادة الفحص'),
            ),
          ],
        ),
      ),
    );
  }
}
