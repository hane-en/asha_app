import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class TestLocalFavorites extends StatefulWidget {
  const TestLocalFavorites({super.key});

  @override
  State<TestLocalFavorites> createState() => _TestLocalFavoritesState();
}

class _TestLocalFavoritesState extends State<TestLocalFavorites> {
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testLocalFavorites();
  }

  Future<void> _testLocalFavorites() async {
    setState(() {
      _isLoading = true;
      _result = 'فحص المفضلة المحلية...\n';
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // فحص المفضلة المحلية
      final localFavorites = prefs.getStringList('local_favorites') ?? [];
      _result += '📋 عدد المفضلة المحلية: ${localFavorites.length}\n';

      if (localFavorites.isNotEmpty) {
        _result += '📋 المفضلة المحلية: ${localFavorites.join(', ')}\n';
      }

      // فحص جميع الخدمات
      _result += '🔍 جلب جميع الخدمات...\n';
      final allServices = await ApiService.getAllServices();
      _result += '📋 عدد جميع الخدمات: ${allServices.length}\n';

      if (allServices.isNotEmpty) {
        _result +=
            '📋 أول 3 خدمات: ${allServices.take(3).map((s) => '${s.id}:${s.title}').join(', ')}\n';
      }

      // فحص الخدمات المفضلة
      if (localFavorites.isNotEmpty && allServices.isNotEmpty) {
        final localFavoritesSet = localFavorites.toSet();
        final filteredServices = allServices.where((service) {
          return localFavoritesSet.contains(service.id.toString());
        }).toList();

        _result +=
            '📋 عدد الخدمات المفضلة المطابقة: ${filteredServices.length}\n';

        if (filteredServices.isNotEmpty) {
          _result +=
              '📋 الخدمات المفضلة: ${filteredServices.map((s) => '${s.id}:${s.title}').join(', ')}\n';
        }
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
        title: const Text('اختبار المفضلة المحلية'),
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
              onPressed: _testLocalFavorites,
              child: const Text('إعادة الاختبار'),
            ),
          ],
        ),
      ),
    );
  }
}
