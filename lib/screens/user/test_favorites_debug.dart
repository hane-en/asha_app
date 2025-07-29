import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class TestFavoritesDebug extends StatefulWidget {
  const TestFavoritesDebug({super.key});

  @override
  State<TestFavoritesDebug> createState() => _TestFavoritesDebugState();
}

class _TestFavoritesDebugState extends State<TestFavoritesDebug> {
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testFavorites();
  }

  Future<void> _testFavorites() async {
    setState(() {
      _isLoading = true;
      _result = 'بدء اختبار المفضلة...\n';
    });

    try {
      // فحص userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      _result += 'User ID: ${userId ?? 'غير محدد'}\n';

      if (userId == null) {
        _result += '❌ لا يوجد user_id محفوظ\n';
        _result += '💡 يجب تسجيل الدخول أولاً\n';
        setState(() => _isLoading = false);
        return;
      }

      // اختبار إضافة مفضلة
      _result += '🔍 اختبار إضافة مفضلة...\n';
      final success = await ApiService.addToFavorites(userId, 1);
      _result += success ? '✅ تم إضافة المفضلة بنجاح\n' : '❌ فشل في إضافة المفضلة\n';

      // اختبار جلب المفضلات
      _result += '🔍 اختبار جلب المفضلات...\n';
      final favorites = await ApiService.getFavorites(userId);
      _result += '📋 عدد المفضلات: ${favorites.length}\n';

      if (favorites.isNotEmpty) {
        _result += '📋 أول مفضلة: ${favorites.first['title'] ?? 'غير محدد'}\n';
      }

      // اختبار إزالة مفضلة
      _result += '🔍 اختبار إزالة مفضلة...\n';
      final removeSuccess = await ApiService.removeFavorite(userId, 1);
      _result += removeSuccess ? '✅ تم إزالة المفضلة بنجاح\n' : '❌ فشل في إزالة المفضلة\n';

    } catch (e) {
      _result += '❌ خطأ: $e\n';
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار المفضلة'),
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
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: _testFavorites,
              child: const Text('إعادة الاختبار'),
            ),
          ],
        ),
      ),
    );
  }
} 