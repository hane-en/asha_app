# العلاقة بين get_active_ads.php وتسجيل الدخول

## 🔍 **سبب ظهور الرابط عند تسجيل الدخول:**

### 1. **تسلسل الأحداث:**
```
تسجيل الدخول → توجيه إلى UserHomePage → تحميل الصفحة الرئيسية → عرض الإعلانات
```

### 2. **التفاصيل:**

**عند تسجيل الدخول:**
1. يتم توجيه المستخدم إلى `UserHomePage`
2. في `initState()` يتم استدعاء `_loadUserData()`, `_loadCategories()`, `_loadFeaturedServices()`
3. في `build()` يتم عرض `AdsCarouselWidget()`

**في AdsCarouselWidget:**
1. في `initState()` يتم استدعاء `_loadAds()`
2. في `_loadAds()` يتم استدعاء `ApiService.getActiveAds()`
3. في `ApiService.getActiveAds()` يتم إرسال طلب إلى `ads/get_active_ads.php`

### 3. **الكود المسؤول:**

**في `lib/screens/user/user_home_page.dart`:**
```dart
// الإعلانات
const AdsCarouselWidget(),
```

**في `lib/widgets/ads_carousel_widget.dart`:**
```dart
Future<void> _loadAds() async {
  try {
    final ads = await ApiService.getActiveAds(); // هنا يتم الطلب
    setState(() {
      _ads = ads;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    print('Error loading ads: $e');
  }
}
```

**في `lib/services/api_service.dart`:**
```dart
static Future<List<AdModel>> getActiveAds() async {
  try {
    final data = await _makeRequest('ads/get_active_ads.php'); // هنا الرابط
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

### 4. **الرابط النهائي:**
```
http://localhost/asha_app_backend/ads/get_active_ads.php
```

## ✅ **هل هذا طبيعي؟**

**نعم، هذا سلوك طبيعي تماماً!**

### الأسباب:
1. **عرض الإعلانات**: الصفحة الرئيسية تحتاج لعرض الإعلانات النشطة
2. **تجربة المستخدم**: الإعلانات تجعل التطبيق أكثر جاذبية
3. **دخل للمزودين**: الإعلانات مصدر دخل للمزودين
4. **معلومات مفيدة**: الإعلانات تعرض عروض وخدمات جديدة

### متى يحدث:
- ✅ عند تسجيل الدخول لأول مرة
- ✅ عند فتح الصفحة الرئيسية
- ✅ عند تحديث الصفحة (pull to refresh)
- ✅ عند العودة للصفحة الرئيسية

## 📊 **ما يحدث في الخادم:**

**في `asha_app_backend/api/ads/get_active_ads.php`:**
```php
// جلب الإعلانات النشطة التي لم تنته صلاحيتها بعد
$query = "SELECT * FROM ads WHERE is_active = 1 AND (end_date IS NULL OR end_date >= CURDATE()) ORDER BY created_at DESC";
$ads = $database->select($query);
```

## 🎯 **النتيجة:**

- **عرض الإعلانات**: في الصفحة الرئيسية
- **تفاعل المستخدم**: يمكن النقر على الإعلانات
- **توجيه للخدمات**: الإعلانات تؤدي لصفحات الخدمات
- **دخل للمزودين**: الإعلانات تروج لخدماتهم

## 📝 **ملاحظات مهمة:**

1. **طبيعي**: هذا طلب API عادي لجلب البيانات
2. **ضروري**: لعرض الإعلانات في الصفحة الرئيسية
3. **آمن**: مجرد طلب GET للقراءة فقط
4. **مفيد**: يحسن تجربة المستخدم

---

**الخلاصة: الرابط يظهر بشكل طبيعي عند تسجيل الدخول لأنه جزء من تحميل الصفحة الرئيسية وعرض الإعلانات!** 🎉 