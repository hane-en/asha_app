# إصلاح مشكلة الفئات والإعلانات

## 🔍 **المشكلة:**
- لا تظهر الفئات في الصفحة الرئيسية
- لا تظهر الإعلانات في الصفحة الرئيسية
- لا تظهر الفئات عند إنشاء حساب مزود

## ✅ **السبب:**
المسارات في `ApiService` كانت خاطئة:
- `services/get_categories.php` بدلاً من `api/categories/get_all.php`
- `services/get_services_with_offers.php` بدلاً من `api/services/get_all.php`
- `ads/get_active_ads.php` بدلاً من `api/ads/get_active_ads.php`

## 🔧 **الحلول المطبقة:**

### 1. **إصلاح مسار الفئات:**
```dart
// في lib/services/api_service.dart
static Future<List<Map<String, dynamic>>> getCategories() async {
  try {
    final data = await _makeRequest('api/categories/get_all.php'); // تم إصلاح المسار
    if (data['success'] == true) {
      final categoriesData = data['data'];
      if (categoriesData is List) {
        return categoriesData
            .where((item) => item is Map<String, dynamic>)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
}
```

### 2. **إصلاح مسار الخدمات:**
```dart
// في lib/services/api_service.dart
static Future<Map<String, dynamic>> getServicesWithOffers({
  int? categoryId,
  int limit = 10,
  int offset = 0,
}) async {
  try {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final data = await _makeRequest('api/services/get_all.php?$queryString'); // تم إصلاح المسار

    if (data['success'] == true) {
      final servicesData = data['data'];
      if (servicesData is List) {
        return {
          'services': servicesData,
          'pagination': data['pagination'] ?? {},
        };
      } else {
        print('Invalid services data format: $servicesData');
        return {'services': [], 'pagination': {}};
      }
    }

    return {'services': [], 'pagination': {}};
  } catch (e) {
    print('Error fetching services with offers: $e');
    return {'services': [], 'pagination': {}};
  }
}
```

### 3. **إصلاح مسار الإعلانات:**
```dart
// في lib/services/api_service.dart
static Future<List<AdModel>> getActiveAds() async {
  try {
    final data = await _makeRequest('api/ads/get_active_ads.php'); // تم إصلاح المسار
    if (data['success'] == true) {
      return List<AdModel>.from(
        data['data'].map((item) => AdModel.fromJson(item)),
      );
    }
    return [];
  } catch (e) {
    print('Error getting active ads: $e');
    return [];
  }
}
```

### 4. **إصلاح باقي مسارات الخدمات:**
```dart
// جميع المسارات تم إصلاحها:
'api/services/get_all.php'
'api/services/get_by_id.php'
'api/services/search.php'
'api/services/advanced_search.php'
'api/services/get_provider_info.php'
```

## 🎯 **النتيجة المتوقعة:**

بعد التطبيق:
```
✅ Categories load successfully
✅ Ads load successfully
✅ Services load successfully
✅ Provider registration shows categories
✅ Home page displays all content
```

## 📝 **خطوات الاختبار:**

**1. إعادة تشغيل Flutter:**
```bash
flutter clean
flutter pub get
flutter run
```

**2. اختبار الصفحة الرئيسية:**
- افتح التطبيق
- سجل دخول كالمستخدم
- تحقق من ظهور الفئات والإعلانات

**3. اختبار إنشاء حساب مزود:**
- اذهب إلى صفحة إنشاء حساب مزود
- تحقق من ظهور الفئات في القائمة

**4. التحقق من Console:**
- يجب ألا تظهر أخطاء في الاتصال
- يجب أن تظهر رسائل نجاح في تحميل البيانات

---

**الآن جرب التطبيق وأخبرني بالنتيجة!** 🎉

**المسارات الصحيحة الآن هي:**
```
http://127.0.0.1/asha_app_backend/api/categories/get_all.php
http://127.0.0.1/asha_app_backend/api/services/get_all.php
http://127.0.0.1/asha_app_backend/api/ads/get_active_ads.php
``` 