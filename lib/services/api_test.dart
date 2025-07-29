import 'api_service.dart';

class ApiTest {
  static Future<void> testServicesConnection() async {
    print('🧪 Testing Services API Connection...');

    try {
      // اختبار جلب جميع الخدمات
      print('📡 Testing getAllServices...');
      final services = await ApiService.getAllServices();
      print('✅ getAllServices result: ${services.length} services');

      if (services.isNotEmpty) {
        print('📋 First service: ${services.first.title}');
      }

      // اختبار جلب الفئات
      print('📡 Testing getCategories...');
      final categories = await ApiService.getCategories();
      print('✅ getCategories result: ${categories.length} categories');

      if (categories.isNotEmpty) {
        print('📋 First category: ${categories.first['title']}');
      }

      // اختبار جلب الخدمات حسب الفئة
      if (categories.isNotEmpty) {
        final categoryId = categories.first['id'].toString();
        print('📡 Testing getServicesByCategory with ID: $categoryId');
        final categoryServices = await ApiService.getServicesByCategory(
          categoryId,
        );
        print(
          '✅ getServicesByCategory result: ${categoryServices.length} services',
        );
      }
    } catch (e) {
      print('❌ API Test Error: $e');
    }
  }

  static Future<void> testSimpleConnection() async {
    print('🧪 Testing Simple API Connection...');

    try {
      // استخدام getAllServices بدلاً من _makeRequest المباشر
      final services = await ApiService.getAllServices();
      print('✅ Simple API test result: ${services.length} services');
      if (services.isNotEmpty) {
        print('📋 First service: ${services.first.title}');
      }
    } catch (e) {
      print('❌ Simple API Test Error: $e');
    }
  }
}
