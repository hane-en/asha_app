import 'package:flutter/material.dart';
import 'services/unified_data_service.dart';

class TestUnifiedData extends StatefulWidget {
  @override
  _TestUnifiedDataState createState() => _TestUnifiedDataState();
}

class _TestUnifiedDataState extends State<TestUnifiedData> {
  String _result = 'بدء الاختبار...';
  bool _isLoading = false;
  Map<String, List<dynamic>> _allData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختبار جميع البيانات - طريقة موحدة')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllData,
              child: Text('اختبار جميع البيانات'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              CircularProgressIndicator()
            else
              Expanded(
                child: Column(
                  children: [
                    Text(_result, style: TextStyle(fontFamily: 'monospace')),
                    SizedBox(height: 16),
                    if (_allData.isNotEmpty) ...[
                      Text(
                        'البيانات المجلوبة:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _allData.length,
                          itemBuilder: (context, index) {
                            final key = _allData.keys.elementAt(index);
                            final data = _allData[key]!;
                            return ExpansionTile(
                              title: Text('$key (${data.length})'),
                              children: data.take(3).map((item) {
                                return ListTile(
                                  title: Text(item.toString()),
                                  subtitle: Text('${item.runtimeType}'),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAllData() async {
    setState(() {
      _isLoading = true;
      _result = 'بدء اختبار جميع البيانات...\n';
      _allData.clear();
    });

    try {
      // اختبار جلب الفئات
      _result += '🔍 اختبار جلب الفئات...\n';
      final categories = await UnifiedDataService.getCategories();
      _result += '✅ تم جلب ${categories.length} فئة\n';
      _allData['categories'] = categories;

      if (categories.isNotEmpty) {
        _result += '📋 أول فئة: ${categories.first['title']}\n';
      }

      // اختبار جلب الخدمات
      _result += '\n🔍 اختبار جلب الخدمات...\n';
      final servicesResult = await UnifiedDataService.getServices(limit: 10);
      final services = servicesResult['services'] ?? [];
      _result += '✅ تم جلب ${services.length} خدمة\n';
      _allData['services'] = services;

      if (services.isNotEmpty) {
        _result += '📋 أول خدمة: ${services.first['title']}\n';
      }

      // اختبار جلب الإعلانات
      _result += '\n🔍 اختبار جلب الإعلانات...\n';
      final ads = await UnifiedDataService.getAds();
      _result += '✅ تم جلب ${ads.length} إعلان\n';
      _allData['ads'] = ads;

      if (ads.isNotEmpty) {
        _result += '📋 أول إعلان: ${ads.first['title']}\n';
      }

      // اختبار جلب المستخدمين
      _result += '\n🔍 اختبار جلب المستخدمين...\n';
      final users = await UnifiedDataService.getUsers();
      _result += '✅ تم جلب ${users.length} مستخدم\n';
      _allData['users'] = users;

      if (users.isNotEmpty) {
        _result += '📋 أول مستخدم: ${users.first['name']}\n';
      }

      // اختبار جلب الحجوزات
      _result += '\n🔍 اختبار جلب الحجوزات...\n';
      final bookings = await UnifiedDataService.getBookings();
      _result += '✅ تم جلب ${bookings.length} حجز\n';
      _allData['bookings'] = bookings;

      if (bookings.isNotEmpty) {
        _result += '📋 أول حجز: ${bookings.first['service_title']}\n';
      }

      // اختبار جلب التقييمات
      _result += '\n🔍 اختبار جلب التقييمات...\n';
      final reviews = await UnifiedDataService.getReviews();
      _result += '✅ تم جلب ${reviews.length} تقييم\n';
      _allData['reviews'] = reviews;

      if (reviews.isNotEmpty) {
        _result += '📋 أول تقييم: ${reviews.first['rating']} نجوم\n';
      }

      // اختبار جلب المفضلة
      _result += '\n🔍 اختبار جلب المفضلة...\n';
      final favorites = await UnifiedDataService.getFavorites();
      _result += '✅ تم جلب ${favorites.length} مفضلة\n';
      _allData['favorites'] = favorites;

      if (favorites.isNotEmpty) {
        _result += '📋 أول مفضلة: ${favorites.first['service_title']}\n';
      }

      _result += '\n🎉 تم اختبار جميع البيانات بنجاح!\n';
    } catch (e) {
      _result += '❌ خطأ: $e\n';
    }

    setState(() {
      _isLoading = false;
    });
  }
}
